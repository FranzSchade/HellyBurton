extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer

func _ready():
	Inventory.inventory_updated.connect(_update_hotbar_ui)
	_update_hotbar_ui()

func _update_hotbar_ui():
	clear_hotbar_container()
	for i in range(Inventory.hotbar_inventory.size()):
		var slot = Inventory.InventorySlot.instantiate()
		slot.set_hotbar_index(i)
		h_box_container.add_child(slot)
		if Inventory.hotbar_inventory[i] != null:
			slot.set_item(Inventory.hotbar_inventory[i])
		else:
			slot.set_empty()
		
	
func clear_hotbar_container():
	while h_box_container.get_child_count() > 0:
		var child = h_box_container.get_child(0)
		h_box_container.remove_child(child)
		child.queue_free()

func set_equipped(slot_index):
	for i in range(Inventory.hotbar_inventory.size()):
		if i == slot_index:
			h_box_container.get_child(i).border_equipped.visible = true
		else:
			h_box_container.get_child(i).border_equipped.visible = false
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hotbar_1") and Inventory.hotbar_inventory[0] != null and Inventory.hotbar_inventory[0]["item_type"] == "equippable":
		Inventory.player_node.equipped_item = Inventory.hotbar_inventory[0]
		set_equipped(0)
	elif event.is_action_pressed("hotbar_2") and Inventory.hotbar_inventory[1] != null and Inventory.hotbar_inventory[1]["item_type"] == "equippable":
		Inventory.player_node.equipped_item = Inventory.hotbar_inventory[1]
		set_equipped(1)
	elif event.is_action_pressed("hotbar_3") and Inventory.hotbar_inventory[2] != null and Inventory.hotbar_inventory[2]["item_type"] == "equippable":
		Inventory.player_node.equipped_item = Inventory.hotbar_inventory[2]
		set_equipped(2)
	elif event.is_action_pressed("hotbar_4") and Inventory.hotbar_inventory[3] != null and Inventory.hotbar_inventory[3]["item_type"] == "equippable":
		Inventory.player_node.equipped_item = Inventory.hotbar_inventory[3]
		set_equipped(3)
	elif event.is_action_pressed("hotbar_5") and Inventory.hotbar_inventory[4] != null and Inventory.hotbar_inventory[4]["item_type"] == "equippable":
		Inventory.player_node.equipped_item = Inventory.hotbar_inventory[4]
		set_equipped(4)
	else:
		return
	Inventory.player_node.equip_slot.get_child(1).texture = Inventory.player_node.equipped_item["item_texture"]
	
	
	
