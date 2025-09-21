extends CharacterBody2D

@export var speed := 75.0
var chasing := false
var player: Node2D = null

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $Timer

func _physics_process(_delta: float) -> void:
	if chasing and player:
		# Ziel für Pathfinding setzen
		nav_agent.target_position = player.global_position
		
		# Nächster Punkt auf dem Pfad
		var next_point := nav_agent.get_next_path_position()

		# Richtung dorthin
		var direction := (next_point - global_position).normalized()
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	_update_animation()


func _update_animation() -> void:
	if velocity == Vector2.ZERO:
		anim.play("idle_front")
	else:
		if abs(velocity.x) > abs(velocity.y):
			anim.play("flight_side")
			anim.flip_h = velocity.x < 0
		elif velocity.y < 0:
			anim.play("flight_back")
		else:
			anim.play("flight_front")


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
	if nav_agent.target_position != player.global_position:
			nav_agent.target_position = player.global_position
	timer.start()
