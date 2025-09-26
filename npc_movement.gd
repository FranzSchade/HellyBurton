extends CharacterBody2D

@export var speed := 75.0
var chasing := false
var player: Node2D = null
var health = 50
var max_health = 50
var stop_distance = 35

var is_hurt = false
var is_dead = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $Timer


func _physics_process(_delta: float) -> void:
	if is_dead:
		return  # Keine Bewegung mehr nach dem Tod

	if chasing and player:
		nav_agent.target_position = player.global_position

		var distance = global_position.distance_to(player.global_position)

		if distance <= stop_distance:
			velocity = Vector2.ZERO
		else:
			var next_point := nav_agent.get_next_path_position()
			var direction := (next_point - global_position).normalized()
			velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if not is_hurt and not is_dead: # Nur wechseln, wenn nicht verletzt/tot
		_update_animation()


func _update_animation() -> void:
	if velocity == Vector2.ZERO:
		anim.play("idle_down")
	else:
		if abs(velocity.x) > abs(velocity.y):
			anim.play("flight_side")
			anim.flip_h = velocity.x < 0
		elif velocity.y < 0:
			anim.play("flight_back")
		else:
			anim.play("flight_down")


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		chasing = true
		player = body
		timer.start()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		chasing = false
		player = null
		timer.stop()


func _on_timer_timeout() -> void:
	if player and nav_agent.target_position != player.global_position:
		nav_agent.target_position = player.global_position
	timer.start()


func damage(amount: int) -> void:
	if is_dead:
		return

	health = clamp(health - amount, 0, max_health)
	is_hurt = true
	anim.play("hurt_down")

	# Nach Ende der Animation zurück in den Normalzustand
	await anim.animation_finished
	is_hurt = false

	if health <= 0:
		die()


func die() -> void:
	is_dead = true
	anim.play("death_side")
	await anim.animation_finished
	queue_free()
