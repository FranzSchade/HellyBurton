class_name QuestManager
extends Node2D

@export_file("*.json") var quest_text_file: String
@onready var background_quest: ColorRect = $"../PlayerHUD/BackgroundQuest"
@onready var quest_name: Label = $"../PlayerHUD/BackgroundQuest/QuestName"
@onready var quest_text: Label = $"../PlayerHUD/BackgroundQuest/QuestText"

var current_quest := {}
var quest_title := ""
var quest_task := ""
var quest_dict = {}

func _ready():
	quest_dict = load_quest_text()

func load_quest_text() -> Dictionary:
	if FileAccess.file_exists(quest_text_file):
		var file := FileAccess.open(quest_text_file, FileAccess.READ)
		var text := file.get_as_text()
		var result = JSON.parse_string(text)
		if typeof(result) == TYPE_DICTIONARY:
			return result
	return {}

func set_quest(quest_key):
	current_quest = quest_dict[quest_key].duplicate()
	quest_name.text = current_quest["title"]
	quest_text.text = current_quest["task"]
	background_quest.visible = true
	
