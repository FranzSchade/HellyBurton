extends CharacterBody2D

@export var speed := 75
@export var sprint_speed := 125
var anim: AnimatedSprite2D

func _ready():
	anim = $AnimatedSprite2D

func _physics_process(_delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")
	input_vector.y = Input.get_action_strength("walk_down") - Input.get_action_strength("walk_up")
	
	input_vector = input_vector.normalized()

	if Input.is_action_pressed("sprint"):
		velocity = input_vector * sprint_speed
	else:
		velocity = input_vector * speed
	move_and_slide()

	# Animation wechseln
	if velocity.length() == 0:
		anim.play("idle_base_down")
	elif velocity.x != 0:
		if Input.is_action_pressed("sprint"):
			anim.play("run_base_side")
		else:
			anim.play("walk_base_side")
	elif velocity.y < 0:
		if Input.is_action_pressed("sprint"):
			anim.play("run_base_up")
		else:
			anim.play("walk_base_up")
	else:
		if Input.is_action_pressed("sprint"):
			anim.play("run_base_down")
		else:
			anim.play("walk_base_down")

	# Flip, wenn nötig (links/rechts)
	if velocity.x < 0:
		anim.flip_h = true
	elif velocity.x > 0:
		anim.flip_h = false
