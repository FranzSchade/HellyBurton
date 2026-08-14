extends Node

signal display_dialog(text_key)
signal cutscene_dialog(text_key)
signal dialog_finished()
signal dialog_started()

var dialog_active := false
var cutscene_active := false
var completed_dialogs: Dictionary = {}

func is_player_locked() -> bool:
	return dialog_active

func complete_dialog(dialog_key: String) -> void:
	if dialog_key.is_empty():
		return
	completed_dialogs[dialog_key] = true

func is_dialog_complete(dialog_key: String) -> bool:
	return completed_dialogs.has(dialog_key)
