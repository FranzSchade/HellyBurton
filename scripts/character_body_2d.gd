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
var _interact_prompts: Dictionary = {}

# === NODES ===
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var cutscene_player: AnimationPlayer = $"../CutscenePlayer"
@onready var health_bar: TextureProgressBar = $"../PlayerHUD/HealthBar"
@onready var inventory_canvas: CanvasLayer = $"../InventoryUI"
@onready var inventory_panel: Control = $"../InventoryUI/Inventory"
@onready var interact_canvas: CanvasLayer = $InteractCanvas
@onready var interact_label: Label = $InteractCanvas/ColorRect/Label
@onready var inventory_hotbar: CanvasLayer = $"../InventoryHotbar"
@onready var equip_slot: Control = $"../PlayerHUD/EquipSlot"
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
	SignalBus.dialog_started.connect(_refresh_interact_prompt)
	SignalBus.dialog_finished.connect(_refresh_interact_prompt)
	cutscene_player.animation_finished.connect(_on_cutscene_finished)


func _is_busy() -> bool:
	return SignalBus.dialog_active or cutscene_player.is_playing()


# === PHYSICS ===
func _physics_process(_delta: float) -> void:
	if _is_busy():
		velocity = Vector2.ZERO
		move_and_slide()
		update_animation()
		return

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
		if SignalBus.dialog_active:
			return
		inventory_canvas.visible = true
		inventory_panel.visible = not inventory_panel.visible
		return

	if _is_busy():
		return

	if event.is_action_pressed("hit") and not is_attacking and not attack_cooldown and not inventory_panel.visible:
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
		anim_name = "hit_%s_%d" % ["side" if direction in ["left", "right"] else direction, last_attack_index[direction]]
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


# === INTERACT PROMPT ===
func set_interact_prompt(source: String, text: String) -> void:
	_interact_prompts[source] = text
	_refresh_interact_prompt()


func clear_interact_prompt(source: String) -> void:
	_interact_prompts.erase(source)
	_refresh_interact_prompt()


func _refresh_interact_prompt() -> void:
	if _interact_prompts.is_empty() or SignalBus.is_player_locked():
		interact_canvas.visible = false
		return
	interact_canvas.visible = true
	if "Pick up" in _interact_prompts.values():
		interact_label.text = "Pick up"
	else:
		interact_label.text = _interact_prompts.values()[0]


func _on_cutscene_finished(_anim_name: StringName) -> void:
	cutscene_player.speed_scale = 1.0
	process_mode = Node.PROCESS_MODE_INHERIT
	SignalBus.cutscene_active = false


# === CUTSCENE ===
func _on_cutscene_trigger_body_entered(body: Node2D, cutscene_name: String, sender_name: String, quest_count: int) -> void:
	if body.is_in_group("Player") and quest_manager.quest_counter >= quest_count:
		cutscene_player.play(cutscene_name)
		await cutscene_player.animation_finished
		var sender = get_node_or_null("../Dialog_Cutscenes/" + sender_name)
		if sender:
			sender.queue_free()
