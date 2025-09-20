extends CharacterBody2D

@export var speed := 75
@export var sprint_speed := 125
var anim: AnimatedSprite2D

@onready var cutscene_player: AnimationPlayer = $"../CutscenePlayer"
@onready var camera_2d: Camera2D = $Camera2D

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


func _on_cutscene_trigger_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("play vamp")
		cutscene_player.play("vamp_cutscene_1")


func _on_cutscene_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "vamp_cutscene_1":
		print("finished")
		# Wir tweenen den offset von -150 zurück auf 0 in 1 Sekunde
		var tween := create_tween()
		tween.tween_property(camera_2d, "offset:y", 0, 1.0) # 1 Sekunde
		# Optional: easing anpassen
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_IN_OUT)
