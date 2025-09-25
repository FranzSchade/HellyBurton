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
