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
var active_quest := false
var quest_requiry = {}
var quest_counter = 0

func _ready():
	quest_dict = load_quest_text()

func _process(_delta):
	if active_quest:
		var quest_party = len(quest_requiry)
		var done = 0
		for key in quest_requiry:
			if Inventory.get_item(key) >= quest_requiry[key]:
				done += 1
				print("Requirements fulfilled")
				quest_requiry.erase(key)
		if done == quest_party:
			print("quest_done")
			active_quest = false
			quest_text.text = "Done!!"
			quest_counter += 1

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
	current_quest = quest_dict[quest_key].duplicate()
	quest_name.text = current_quest["title"]
	quest_text.text = current_quest["task"]
	quest_requiry = current_quest["items"]
	background_quest.visible = true

	
