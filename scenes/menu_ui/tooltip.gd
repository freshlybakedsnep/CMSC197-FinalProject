extends Panel
class_name ActionTooltip

@onready var action_name: Label = $MarginContainer/VBoxContainer/Title/ActionName
@onready var level: Label = $MarginContainer/VBoxContainer/Title/Level

@onready var cooldown: Label = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Cooldown
@onready var description: Label = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Description

func update_display(input: Dictionary) -> void:
	action_name.text = input["name"]
	level.text = "[LV. " + input["level"] + "]" 
	cooldown.text = "CD: " + input["cd"]
	description.text = input["desc"]
