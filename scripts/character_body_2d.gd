extends CharacterBody2D

@export var speed := 125
@export var max_health := 100
@export var tool = ""
#@export enum Tool {
#    NONE,
#    SWORD,
#    AXE,
#    PICKAXE
#}


var health = max_health

var anim: AnimatedSprite2D
@onready var cutscene_player: AnimationPlayer = $"../CutscenePlayer"
@onready var camera_2d: Camera2D = $Camera2D
@onready var health_bar: TextureProgressBar = $"../PlayerHUD/HealthBar"
@onready var inventory_canvas: CanvasLayer = $"../InventoryUI"
@onready var pick_up_canvas: CanvasLayer = $PickUpCanvas
@onready var inventory_hotbar: CanvasLayer = $"../InventoryHotbar"
@onready var hitbox_up: CollisionShape2D = $AreaUp/HitboxUp
@onready var hitbox_right: CollisionShape2D = $AreaRight/HitboxRight
@onready var hitbox_left: CollisionShape2D = $AreaLeft/HitboxLeft
@onready var hitbox_down: CollisionShape2D = $AreaDown/HitboxDown

# --- Schlag-Variablen ---
var is_attacking: bool = false
var attack_cooldown: bool = false
var last_attack_index := {"up": 1, "down": 1, "left": 1, "right": 1} # Merkt sich letzte Attacke
var last_direction = "down"

func _ready():
	anim = $AnimatedSprite2D
	health_bar.max_value = max_health
	health_bar.value = health
	Inventory.set_player(self)
	
func _physics_process(_delta):
	# Bewegung blockieren bei Attacke oder Cooldown
	if is_attacking or attack_cooldown:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left")
	input_vector.y = Input.get_action_strength("walk_down") - Input.get_action_strength("walk_up")
	
	# Normalisieren → diagonale Bewegungen nicht schneller
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

	# Animation wechseln (nur wenn nicht im Angriff)
	if velocity.length() == 0:
		match last_direction:
			"left":
				anim.play("idle_side")
				anim.flip_h = true
			"right":
				anim.play("idle_side")
			"up":
				anim.play("idle_up")
			"down":
				anim.play("idle_down")
			
	elif velocity.x != 0:
		anim.play("walk_side")
	elif velocity.y < 0:
		anim.play("walk_up")
		last_direction = "up"
	else:
		anim.play("walk_down")
		last_direction = "down"

	# Flip für Seitenbewegung
	if velocity.x < 0:
		anim.flip_h = true
		last_direction = "left"
	elif velocity.x > 0:
		anim.flip_h = false
		last_direction = "right"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory"):
		inventory_canvas.visible = not inventory_canvas.visible
		
	if event.is_action_pressed("hit") and not is_attacking and not attack_cooldown and not inventory_canvas.visible:
		match tool:
			"Sword":
				attack()
			"Axe":
				tool_use("chop")
			"Pickaxe":
				tool_use("mine")

	
func tool_use(tool_name) -> void:
	is_attacking = true

	# Richtung zur Maus berechnen
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()

	var tool_dir := "down"
	if abs(dir.x) > abs(dir.y):
		tool_dir = "right" if dir.x > 0 else "left"
	elif dir.y < 0:
		tool_dir = "up"
	else:
		tool_dir = "down"

	# Animation wählen (nur eine pro Richtung)
	if tool_dir == "left":
		anim.play("%s_side" % tool_name)
		anim.flip_h = true
	elif tool_dir == "right":
		anim.play("%s_side" % tool_name)
		anim.flip_h = false
	else:
		anim.play("%s_side" % tool_name)
		#anim.play("%s_%s" % [tool_name, tool_dir])


	# Hitbox aktivieren
	_enable_hitbox(tool_dir)

	# Hitbox nach kurzer Zeit deaktivieren
	await get_tree().create_timer(0.15).timeout
	_disable_all_hitboxes()

	# Warten bis Animation fertig
	await anim.animation_finished
	is_attacking = false

	# Kurzer Cooldown
	attack_cooldown = true
	await get_tree().create_timer(0.25).timeout
	attack_cooldown = false
	
func attack() -> void:
	is_attacking = true

	# Richtung zur Maus berechnen
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - global_position).normalized()

	var attack_dir := "down"
	if abs(dir.x) > abs(dir.y):
		attack_dir = "right" if dir.x > 0 else "left"
	elif dir.y < 0:
		attack_dir = "up"
	else:
		attack_dir = "down"

	# Abwechseln zwischen 1 und 2
	var index = last_attack_index[attack_dir]
	var next_index = (index % 2) + 1
	last_attack_index[attack_dir] = next_index

	# Animationsname bauen
	var anim_name = "hit_%s_%d" % [attack_dir, next_index]

	# Seiten-Animation + Flip
	if attack_dir == "left":
		anim.play("hit_side_%d" % [next_index])
		anim.flip_h = true
	elif attack_dir == "right":
		anim.play("hit_side_%d" % [next_index])
		anim.flip_h = false
	else:
		anim.play(anim_name)

	# Hitbox aktivieren
	_enable_hitbox(attack_dir)

	# Hitbox nach kurzer Zeit deaktivieren
	await get_tree().create_timer(0.15).timeout
	_disable_all_hitboxes()

	# Warten bis Animation fertig
	await anim.animation_finished
	is_attacking = false

	# Kurzer Cooldown
	attack_cooldown = true
	await get_tree().create_timer(0.2).timeout
	attack_cooldown = false


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


func _on_cutscene_trigger_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("play vamp")
		cutscene_player.play("vamp_cutscene_1")
		print(cutscene_player.current_animation_length)
		
func damage(amount: int) -> void:
	health = clamp(health - amount, 0, max_health)
	health_bar.value = health
	if health <= 0:
		pass
		
func heal(amount: int) -> void:
	health = clamp(health + amount, 0, max_health)
	health_bar.value = health
	
	
func apply_item_effect(item):
	match item["effect"]:
		"Stamina":
			speed += 50
		"Health":
			heal(item["amount"])


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.damage(10)
	if body.is_in_group("Tree"):
		print("chopped")
		body.chop()
	if body.is_in_group("Rock"):
		body.mine()
