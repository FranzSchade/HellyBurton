extends StaticBody2D

@export var health := 3
@export var wood_drop := 2
const WOOD = preload("uid://bgsl6pn6yn6v3")
const INVENTORY_ITEM = preload("uid://b8vkxp76qk3t2")

var wood = {
		"item_quantity" = 1,
		"item_type" = "material",
		"item_name" = "wood",
		"item_texture"= WOOD,
		"item_effect" = "just wood",
		"scene_path" = INVENTORY_ITEM,
		"stackable" = true,
		"in_hotbar" = false
		
	}

func chop():
	health -= 1
	if health <= 0:
		drop_wood()
		queue_free()

func drop_wood() -> void:
	var drop_position = global_position

	# Neues Dictionary, damit das Original nicht überschrieben wird
	var wood_drop_item = wood.duplicate(true)

	# Zufällige Menge zwischen 2 und 8
	wood_drop_item["item_quantity"] = randi_range(2, 8)

	# Zufällige Position in einem kleinen Kreis um den Baum
	var angle = randf_range(0, TAU)
	var radius = randf_range(10.0, 25.0)
	var drop_offset = Vector2(radius, 0).rotated(angle)

	# Item ins Spiel droppen
	print(wood_drop_item)
	Inventory.drop_item(wood_drop_item, drop_position + drop_offset)
