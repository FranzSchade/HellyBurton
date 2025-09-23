extends Control
@onready var grid_container: GridContainer = $GridContainer

func center_inventory():
	var viewport_size = get_viewport().get_visible_rect().size
	var bg_size = self.get_size()
	# Horizontale Mitte, Y-Offset = 20 Pixel vom oberen Rand
	self.position = Vector2((viewport_size.x - bg_size.x) / 2, 100)

func _ready() -> void:
	center_inventory()
	Inventory.inventory_updated.connect(_on_inventory_updated)
	_on_inventory_updated()
	
func _on_inventory_updated():
	clear_grid_container()
	for item in Inventory.inventory:
		var slot = Inventory.InventorySlot.instantiate()
		grid_container.add_child(slot)
		if item != null:
			slot.set_item(item)
		else:
			slot.set_empty()
	
func clear_grid_container():
	while grid_container.get_child_count() > 0:
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()
