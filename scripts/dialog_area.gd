extends Area2D

@export var dialog_key = ""
@export var one_time := false
@export var on_entered := false

var area_active := false
var triggered_once := false
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _input(event: InputEvent) -> void:
	if area_active and event.is_action_pressed("interact"):
		print("signal")
		print(dialog_key)
		SignalBus.emit_signal("display_dialog", dialog_key)
		if one_time:
			triggered_once = true


func _on_body_entered(_body: Node) -> void:
	if triggered_once:
		return
	area_active = true
	if on_entered == true:
		SignalBus.emit_signal("display_dialog", dialog_key)
		


func _on_body_exited(_body: Node) -> void:
	print("exited")
	if one_time:
		collision_shape_2d.set_deferred("disabled", true)
	area_active = false
