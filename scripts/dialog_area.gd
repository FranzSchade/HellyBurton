extends Area2D

@export var dialog_key = ""
@export var one_time := false
@export var on_entered := false
@export var required_dialog := ""

var area_active := false
var triggered_once := false
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready():
	SignalBus.dialog_finished.connect(_on_dialog_finished)


func _is_unlocked() -> bool:
	return required_dialog.is_empty() or SignalBus.is_dialog_complete(required_dialog)


func _prompt_id() -> String:
	return str(get_instance_id())


func _show_talk_prompt(body: Node) -> void:
	if body.has_method("set_interact_prompt") and _is_unlocked() and not on_entered:
		body.set_interact_prompt(_prompt_id(), "Talk")


func _hide_talk_prompt(body: Node) -> void:
	if body.has_method("clear_interact_prompt"):
		body.clear_interact_prompt(_prompt_id())


func _start_own_dialog() -> void:
	if not _is_unlocked() or triggered_once:
		return
	SignalBus.emit_signal("display_dialog", dialog_key)
	if one_time:
		triggered_once = true


func _input(event: InputEvent) -> void:
	if SignalBus.dialog_active:
		return
	if area_active and event.is_action_pressed("interact"):
		_start_own_dialog()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("Player"):
		return
	if triggered_once:
		return
	area_active = true
	_show_talk_prompt(body)
	if on_entered:
		_start_own_dialog()


func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("Player"):
		return
	_hide_talk_prompt(body)
	area_active = false


func _on_dialog_finished():
	if not triggered_once:
		return
	area_active = false
	collision_shape_2d.set_deferred("disabled", true)
	if Inventory.player_node:
		_hide_talk_prompt(Inventory.player_node)
