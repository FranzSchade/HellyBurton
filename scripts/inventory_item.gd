@tool
extends Node2D

@export var item_type = ""
@export var item_name = ""
@export var item_texture: Texture
@export var item_effect = ""
@export var stackable: bool
@export var item_quantity: int
var scene_path = preload("uid://b8vkxp76qk3t2")
var player_in_range = false
var in_hotbar = false

@onready var icon: Sprite2D = $Sprite2D

func _ready() -> void:
	if not Engine.is_editor_hint():
		icon.texture = item_texture
		
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		icon.texture = item_texture
	if player_in_range and not SignalBus.is_player_locked() and Input.is_action_pressed("pick_up"):
		pickup_item()
		
func pickup_item():
	var item = {
		"item_quantity" = item_quantity,
		"item_type" = item_type,
		"item_name" = item_name,
		"item_texture"= item_texture,
		"item_effect" = item_effect,
		"scene_path" = scene_path,
		"stackable" = stackable,
		"in_hotbar" = in_hotbar
		
	}
	if Inventory.player_node:
		Inventory.player_node.clear_interact_prompt(_prompt_id())
		Inventory.add_item(item, false)
		self.queue_free()


func _prompt_id() -> String:
	return str(get_instance_id())


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		body.set_interact_prompt(_prompt_id(), "Pick up")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		body.clear_interact_prompt(_prompt_id())
		
func set_item_data(data):
	item_type = data["item_type"]
	item_name = data["item_name"]
	item_texture = data["item_texture"]
	item_effect = data["item_effect"]
	scene_path = data["scene_path"]
	stackable = data["stackable"]
	in_hotbar = data["in_hotbar"]
	item_quantity = data["item_quantity"]
