@tool
extends Node2D

@export var item_type = ""
@export var item_name = ""
@export var item_texture: Texture
@export var item_effect = ""
@export var stackable: bool
var scene_path = preload("uid://b8vkxp76qk3t2")
var player_in_range = false

@onready var icon: Sprite2D = $Sprite2D

func _ready() -> void:
	if not Engine.is_editor_hint():
		icon.texture = item_texture
		
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		icon.texture = item_texture
	if player_in_range and Input.is_action_pressed("pick_up"):
		pickup_item()
		
func pickup_item():
	var item = {
		"quantity" = 1,
		"item_type" = item_type,
		"item_name" = item_name,
		"item_texture"= item_texture,
		"item_effect" = item_effect,
		"scene_path" = scene_path,
		"stackable" = stackable
	}
	if Inventory.player_node:
		Inventory.add_item(item)
		self.queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		body.pick_up_canvas.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		body.pick_up_canvas.visible = false
