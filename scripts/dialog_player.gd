extends CanvasLayer

@export_file("*.json") var scene_text_file: String

var scene_text: Dictionary = {}
var selected_text: Array = []
var in_progress := false

@onready var background: TextureRect = $Background
@onready var label: Label = $Label
@onready var color_rect: ColorRect = $Background/ColorRect
@onready var label_2: Label = $Label2

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
	SignalBus.display_dialog.connect(on_display_dialog) # Godot 4 Signal-Verbindung
	SignalBus.cutscene_dialog.connect(on_cutscene_dialog)
	
	
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
	get_tree().paused = false

func on_display_dialog(text_key):
	if in_progress:
		next_line()
	else:
		get_tree().paused = true
		background.visible = true
		color_rect.visible = true
		label_2.visible = true
		in_progress = true
		selected_text = scene_text[text_key].duplicate()
		show_text()
		
func on_cutscene_dialog(text_key: String):
	get_tree().paused = true
	background.visible = true
	color_rect.visible = true
	label_2.visible = true
	in_progress = true
	selected_text = scene_text[text_key].duplicate()
	while in_progress:
		next_line()
		await get_tree().create_timer(2).timeout
		
