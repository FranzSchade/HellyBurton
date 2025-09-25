extends Node

var inventory = []
var player_node: Node = null

signal inventory_updated

@onready var InventorySlot = preload("uid://cha06ymdrtac7")

var hotbar_inventory = []

func _ready():
	inventory.resize(18)
	hotbar_inventory.resize(5)
	
func add_item(item, to_hotbar = false):
	var added_to_hotbar = false
	if to_hotbar:
		added_to_hotbar = add_hotbar_item(item)
		inventory_updated.emit()
	if not added_to_hotbar:
		for i in range(inventory.size()):
			if inventory[i] != null and inventory[i]["item_name"] == item["item_name"] and item["stackable"]:
				inventory[i]["quantity"] += 1
				inventory_updated.emit()
				print(inventory)
				return true
			elif inventory[i] == null:
				inventory[i] = item
				inventory_updated.emit()
				print(inventory)
				return true
		return false
	
func remove_item(item):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["item_name"] == item["item_name"]:
			if inventory[i]["quantity"] == 1:
				inventory[i] = null
			else:
				inventory[i]["quantity"] -= 1
			inventory_updated.emit()
			return true
	return false
	
	
func adjust_drop_pos(position):
	var radius = 100
	var nearby_items = get_tree().get_nodes_in_group("Item")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var range_offset = Vector2(randf_range(-radius,radius), randf_range(-radius, radius))
			position += range_offset
			break
	return position

func drop_item(item_data, drop_position):
	var item_instance = item_data["scene_path"].instantiate()
	item_instance.set_item_data(item_data)
	drop_position = adjust_drop_pos(drop_position)
	item_instance.global_position = drop_position
	get_tree().current_scene.add_child(item_instance)
	

func add_hotbar_item(item):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i]==null:
			hotbar_inventory[i] = item
			item.in_hotbar = true
			return true
	return false
	
func remove_hotbar_item(item):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null and hotbar_inventory[i]["item_name"] == item["item_name"]:
			if hotbar_inventory[i]["quantity"] == 1:
				hotbar_inventory[i] = null
				item.in_hotbar = false
			else:
				hotbar_inventory[i]["quantity"] -= 1
			inventory_updated.emit()
			return true
	return false
	
func unassign_hotbar_item(item):
	for i in range(hotbar_inventory.size()):
		if hotbar_inventory[i] != null and hotbar_inventory[i]["item_name"] == item["item_name"]:
			hotbar_inventory[i] = null
			item.in_hotbar = false
			inventory_updated.emit()
			return true
	return false

func increase_inventory_size():
	inventory_updated.emit()
	
func set_player(player):
	player_node = player
