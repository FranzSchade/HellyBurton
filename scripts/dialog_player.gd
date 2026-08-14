extends CanvasLayer

@export_file("*.json") var scene_text_file: String

var scene_text: Dictionary = {}
var selected_text: Array = []
var in_progress := false
var current_dialog_key := ""

@onready var background: TextureRect = $Background
@onready var label: Label = $Label
@onready var color_rect: ColorRect = $Background/ColorRect
@onready var label_2: Label = $Label2
@onready var cutscene_player: AnimationPlayer = get_node_or_null("../CutscenePlayer")

func center_dialog():
	var viewport_size = get_viewport().get_visible_rect().size
	var bg_size = background.get_size()
	# Horizontale Mitte, Y-Offset = 20 Pixel vom oberen Rand
	background.position = Vector2((viewport_size.x - bg_size.x) / 2, 20)
	label.position = background.position + Vector2(10,10)
	label_2.position = background.position + bg_size - label_2.get_size() - Vector2(10,10)



func _ready() -> void:
	background.visible = false
	color_rect.visible = false
	label_2.visible = false
	scene_text = load_scene_text()
	center_dialog()
	SignalBus.display_dialog.connect(on_display_dialog)
	SignalBus.cutscene_dialog.connect(on_cutscene_dialog)


func _input(event: InputEvent) -> void:
	if in_progress and event.is_action_pressed("interact"):
		next_line()
		get_viewport().set_input_as_handled()

	
func load_scene_text() -> Dictionary:
	if FileAccess.file_exists(scene_text_file):
		var file := FileAccess.open(scene_text_file, FileAccess.READ)
		var text := file.get_as_text()
		var result = JSON.parse_string(text)
		if typeof(result) == TYPE_DICTIONARY:
			return result
	return {}

func show_text():
	label.text = selected_text.pop_front()

func next_line():
	if selected_text.size() > 0:
		show_text()
	else:
		finish()
		
func finish():
	label.text = ""
	background.visible = false
	color_rect.visible = false
	label_2.visible = false
	in_progress = false
	SignalBus.dialog_active = false
	SignalBus.complete_dialog(current_dialog_key)
	current_dialog_key = ""
	if cutscene_player:
		cutscene_player.speed_scale = 1.0
	SignalBus.dialog_finished.emit()

func on_display_dialog(text_key):
	if in_progress:
		return
	_start_dialog(text_key)


func on_cutscene_dialog(text_key: String):
	if in_progress:
		return
	if cutscene_player:
		cutscene_player.speed_scale = 0.0
	_start_dialog(text_key)


func _start_dialog(text_key: String) -> void:
	SignalBus.dialog_active = true
	SignalBus.dialog_started.emit()
	var inventory_panel := get_node_or_null("../InventoryUI/Inventory")
	if inventory_panel:
		inventory_panel.visible = false
	background.visible = true
	color_rect.visible = true
	label_2.visible = true
	in_progress = true
	current_dialog_key = text_key
	selected_text = scene_text[text_key].duplicate()
	show_text()

		
