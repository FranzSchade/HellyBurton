extends StaticBody2D

@export var health := 3
@export var drop := 2
const STONE = preload("uid://ceqmcb03nfh1o")
const INVENTORY_ITEM = preload("uid://b8vkxp76qk3t2")

# TODO
# Multiple Ore types that get specified via @export variable
# depending which ore type, change quantity, effect, texture etc.#
# e.g. Iron, Gold, Diamond for now just rock
# switch case in mine what item to drop with different drop rates


var ore = {
		"item_quantity" = 1,
		"item_type" = "material",
		"item_name" = "stone",
		"item_texture"= STONE,
		"item_effect" = "just stone",
		"scene_path" = INVENTORY_ITEM,
		"stackable" = true,
		"in_hotbar" = false
		
	}

func mine():
	health -= 1
	if health <= 0:
		drop_ore()
		queue_free()

func drop_ore() -> void:
	var drop_position = global_position

	# Neues Dictionary, damit das Original nicht überschrieben wird
	var ore_drop_item = ore.duplicate(true)

	# Zufällige Menge zwischen 2 und 8
	ore_drop_item["item_quantity"] = randi_range(2, 8)

	# Zufällige Position in einem kleinen Kreis um den Baum
	var angle = randf_range(0, TAU)
	var radius = randf_range(10.0, 25.0)
	var drop_offset = Vector2(radius, 0).rotated(angle)

	# Item ins Spiel droppen
	print(ore_drop_item)
	Inventory.drop_item(ore_drop_item, drop_position + drop_offset)
