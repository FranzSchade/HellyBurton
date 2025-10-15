extends CharacterBody2D

# === EXPORTED VARS ===
@export var speed: float = 125.0
@export var max_health: int = 100

# === STATS ===
var health: int = max_health

# === STATE ===
var is_attacking := false
var attack_cooldown := false
var last_direction := "down"
var last_attack_index := {"up": 1, "down": 1, "left": 1, "right": 1}
var equipped_item: Dictionary = {}

# === NODES ===
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var cutscene_player: AnimationPlayer = $"../CutscenePlayer"
@onready var health_bar: TextureProgressBar = $"../PlayerHUD/HealthBar"
@onready var inventory_canvas: CanvasLayer = $"../InventoryUI"
@onready var pick_up_canvas: CanvasLayer = $PickUpCanvas
@onready var inventory_hotbar: CanvasLayer = $"../InventoryHotbar"
@onready var equip_slot: Control = $"../PlayerHUD/EquipSlot"
@onready var cutscene_trigger_1: Area2D = $"../cutscene_trigger_1"
@onready var cutscene_trigger_2: Area2D = $"../cutscene_trigger_2"
@onready var cutscene_trigger_3: Area2D = $"../cutscene_trigger_3"
@onready var quest_manager: QuestManager = $"../QuestManager"

# Hitboxes
@onready var hitboxes := {
	"up": $AreaUp/HitboxUp,
	"down": $AreaDown/HitboxDown,
	"left": $AreaLeft/HitboxLeft,
	"right": $AreaRight/HitboxRight
}

# === SETUP ===
func _ready():
	health_bar.max_value = max_health
	health_bar.value = health
	Inventory.set_player(self)


# === PHYSICS ===
func _physics_process(_delta: float) -> void:
	if is_attacking or attack_cooldown:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	handle_movement()
	move_and_slide()

	if not is_attacking:
		update_animation()


# === MOVEMENT ===
func handle_movement() -> void:
	var input_vector := Vector2(
		Input.get_action_strength("walk_right") - Input.get_action_strength("walk_left"),
		Input.get_action_strength("walk_down") - Input.get_action_strength("walk_up")
	).normalized()

	velocity = input_vector * speed

	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > abs(input_vector.y):
			last_direction = "right" if input_vector.x > 0 else "left"
		else:
			last_direction = "down" if input_vector.y > 0 else "up"


func update_animation() -> void:
	if velocity == Vector2.ZERO:
		match last_direction:
			"left":
				anim.play("idle_side")
				anim.flip_h = true
			"right":
				anim.play("idle_side")
				anim.flip_h = false
			"up":
				anim.play("idle_up")
			"down":
				anim.play("idle_down")
	else:
		match last_direction:
			"left":
				anim.play("walk_side")
				anim.flip_h = true
			"right":
				anim.play("walk_side")
				anim.flip_h = false
			"up":
				anim.play("walk_up")
			"down":
				anim.play("walk_down")


# === INPUT ===
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory"):
		inventory_canvas.visible = not inventory_canvas.visible
		return

	if event.is_action_pressed("hit") and not is_attacking and not attack_cooldown and not inventory_canvas.visible:
		use_equipped_item()


# === ACTIONS ===
func use_equipped_item() -> void:
	if equipped_item.is_empty():
		return

	var item_name = equipped_item.get("item_name", "")
	if item_name.contains("_sword"):
		attack()
	elif item_name.contains("_axe"):
		tool_use("chop")
	elif item_name.contains("_pickaxe"):
		tool_use("mine")


func attack() -> void:
	await perform_action("hit", true)


func tool_use(tool_name: String) -> void:
	await perform_action(tool_name, false)


# === GENERIC ATTACK FUNCTION ===
func perform_action(base_name: String, use_combo: bool) -> void:
	is_attacking = true

	var mouse_pos := get_global_mouse_position()
	var dir := (mouse_pos - global_position).normalized()
	var direction := get_attack_direction(dir)

	# --- Animation bestimmen ---
	var anim_name: String
	if use_combo:
		var index = last_attack_index[direction]
		last_attack_index[direction] = (index % 2) + 1
		anim_name = "hit_%s_%d" % [direction, last_attack_index[direction]]
	else:
		anim_name = "%s_%s" % [base_name, "side" if direction in ["left", "right"] else direction]

	# Seiten-Animation flippen
	if direction == "left":
		anim.flip_h = true
	elif direction == "right":
		anim.flip_h = false

	anim.play(anim_name)

	# --- Hitboxen ---
	_enable_hitbox(direction)
	await get_tree().create_timer(0.15).timeout
	_disable_hitboxes()

	# --- Ende der Animation ---
	await anim.animation_finished
	is_attacking = false

	# --- Cooldown ---
	attack_cooldown = true
	await get_tree().create_timer(0.25).timeout
	attack_cooldown = false


func get_attack_direction(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	return "up" if dir.y < 0 else "down"


# === HITBOX HANDLING ===
func _enable_hitbox(dir: String) -> void:
	_disable_hitboxes()
	if hitboxes.has(dir):
		hitboxes[dir].set_deferred("disabled", false)


func _disable_hitboxes() -> void:
	for hb in hitboxes.values():
		hb.set_deferred("disabled", true)


# === DAMAGE & HEAL ===
func damage(amount: int) -> void:
	health = clamp(health - amount, 0, max_health)
	health_bar.value = health
	if health <= 0:
		die()


func heal(amount: int) -> void:
	health = clamp(health + amount, 0, max_health)
	health_bar.value = health


func die() -> void:
	queue_free()


# === ITEM EFFECTS ===
func apply_item_effect(item: Dictionary) -> void:
	match item.get("effect", ""):
		"Stamina":
			speed += 50
		"Health":
			heal(item.get("amount", 0))


# === COLLISION EVENTS ===
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.damage(10)
	elif body.is_in_group("Tree"):
		body.chop()
	elif body.is_in_group("Rock"):
		body.mine()


# === CUTSCENE ===
func _on_cutscene_trigger_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		cutscene_player.play("vamp_cutscene_1")
		await cutscene_player.animation_finished
		cutscene_trigger_1.queue_free()


func _on_cutscene_trigger_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		cutscene_player.play("village_cutscene_1")
		await cutscene_player.animation_finished
		cutscene_trigger_2.queue_free()


func _on_cutscene_trigger_3_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and quest_manager.quest_counter >= 1:
		cutscene_player.play("village_cutscene_1_2")
		await cutscene_player.animation_finished
		cutscene_trigger_3.queue_free()
