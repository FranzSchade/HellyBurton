extends CharacterBody2D

@export var speed := 75
var anim: AnimatedSprite2D

func _ready():
	anim = $AnimatedSprite2D

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")
	input_vector.y = Input.get_action_strength("walk_down") - Input.get_action_strength("walk_up")
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

	# Animation wechseln
	if velocity.length() == 0:
		anim.play("idle_base_down")
	elif velocity.x != 0:
		anim.play("walk_base_side")
	elif velocity.y < 0:
		anim.play("walk_base_up")
	else:
		anim.play("walk_base_down")

	# Flip, wenn nötig (links/rechts)
	if velocity.x < 0:
		anim.flip_h = true
	elif velocity.x > 0:
		anim.flip_h = false
