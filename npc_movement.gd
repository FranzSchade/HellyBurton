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

var is_attacking = false
var attack_cooldown = false

@onready var hitbox_up: CollisionShape2D = $AreaUp/HitboxUp
@onready var hitbox_down: CollisionShape2D = $AreaDown/HitboxDown
@onready var hitbox_left: CollisionShape2D = $AreaLeft/HitboxLeft
@onready var hitbox_right: CollisionShape2D = $AreaRight/HitboxRight



func _physics_process(_delta: float) -> void:
	if is_dead or is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	

	if chasing and player:
		nav_agent.target_position = player.global_position

		var distance = global_position.distance_to(player.global_position)

		if distance <= stop_distance:
			velocity = Vector2.ZERO
			attack()
		else:
			var next_point := nav_agent.get_next_path_position()
			var direction := (next_point - global_position).normalized()
			velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if not is_hurt and not is_dead and not is_attacking:
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

func _enable_hitbox(dir: String) -> void:
	_disable_all_hitboxes()
	match dir:
		"up":
			hitbox_up.disabled = false
		"down":
			hitbox_down.disabled = false
		"left":
			hitbox_left.disabled = false
		"right":
			hitbox_right.disabled = false

func _disable_all_hitboxes() -> void:
	hitbox_up.disabled = true
	hitbox_down.disabled = true
	hitbox_left.disabled = true
	hitbox_right.disabled = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("damage"):
			body.damage(10)


func die() -> void:
	is_dead = true
	anim.play("death_side")
	await anim.animation_finished
	queue_free()
	
func attack() -> void:
	if is_attacking or attack_cooldown or is_dead:
		return

	is_attacking = true

	var dir = (player.global_position - global_position).normalized()
	var attack_dir = "down"
	if abs(dir.x) > abs(dir.y):
		attack_dir = "right" if dir.x > 0 else "left"
	elif dir.y < 0:
		attack_dir = "up"
	else:
		attack_dir = "down"

	if attack_dir == "left" or attack_dir == "right":
		anim.play("attack_side")
		anim.flip_h = attack_dir == "left"
	else:
		anim.play("attack_%s" % attack_dir)

	await get_tree().create_timer(0.5).timeout
	_enable_hitbox(attack_dir)

	await anim.animation_finished
	_disable_all_hitboxes()

	is_attacking = false
	attack_cooldown = true
	await get_tree().create_timer(0.25).timeout
	attack_cooldown = false
