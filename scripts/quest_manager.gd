class_name QuestManager
extends Node2D

@export_file("*.json") var quest_text_file: String
@onready var background_quest: ColorRect = $"../PlayerHUD/BackgroundQuest"
@onready var quest_name: Label = $"../PlayerHUD/BackgroundQuest/QuestName"
@onready var quest_text: Label = $"../PlayerHUD/BackgroundQuest/QuestText"

var current_quest := {}
var quest_dict = {}
var active_quest := false
var quest_requiry = {}
var quest_counter = 0

func _ready():
	quest_dict = load_quest_text()
	Inventory.inventory_updated.connect(_update_quest_progress)


func load_quest_text() -> Dictionary:
	if FileAccess.file_exists(quest_text_file):
		var file := FileAccess.open(quest_text_file, FileAccess.READ)
		var text := file.get_as_text()
		var result = JSON.parse_string(text)
		if typeof(result) == TYPE_DICTIONARY:
			return result
	return {}


func set_quest(quest_key):
	active_quest = true
	current_quest = quest_dict[quest_key].duplicate(true)
	quest_name.text = current_quest["title"]
	quest_requiry = current_quest["items"].duplicate(true)
	background_quest.visible = true
	_update_quest_progress()


func _update_quest_progress() -> void:
	if not active_quest:
		return

	var all_done := true
	var lines: PackedStringArray = []
	for item_name in quest_requiry:
		var need: int = int(quest_requiry[item_name])
		var have: int = maxi(Inventory.get_item(item_name), 0)
		lines.append("Gather %s (%d/%d)" % [item_name.capitalize(), mini(have, need), need])
		if have < need:
			all_done = false

	quest_text.text = "\n".join(lines)
	if all_done:
		quest_text.text = "Done!!"
		active_quest = false
		quest_counter += 1
