extends Node

var inventory = []
var player_node: Node = null

signal inventory_updated

@onready var InventorySlot = preload("uid://cha06ymdrtac7")

func _ready():
	inventory.resize(18)
	
	
func add_item(item):
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
	
		
	inventory_updated.emit()
	
func remove_item():
	inventory_updated.emit()
	
func increase_inventory_size():
	inventory_updated.emit()
	
func set_player(player):
	player_node = player
