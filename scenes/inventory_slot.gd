extends Control

@onready var item_button: Button = $ItemButton
@onready var item_name: Label = $Details/ItemName
@onready var item_type: Label = $Details/ItemType
@onready var item_effect: Label = $Details/ItemEffect
@onready var item_icon: Sprite2D = $ItemIcon
@onready var item_quantity: Label = $ItemQuantity
@onready var details: ColorRect = $Details
@onready var usage: ColorRect = $Usage

var item = null

func _on_item_button_pressed() -> void:
	if item != null:
		usage.visible = not usage.visible
		details.visible = not usage.visible


func _on_item_button_mouse_entered() -> void:
	print("test")
	if item != null:
		usage.visible = false
		details.visible = true


func _on_item_button_mouse_exited() -> void:
	if item != null:
		details.visible = false
		usage.visible = false
		
func set_empty():
	item_icon.texture = null
	item_quantity.text = ""
	
func set_item(new_item):
	item = new_item
	item_name.text = new_item["item_name"]
	item_type.text = new_item["item_type"]
	item_icon.texture = new_item["item_texture"]
	item_effect.text = new_item["item_effect"]
	if new_item["stackable"]:
		item_quantity.text = new_item["quantity"]
	
