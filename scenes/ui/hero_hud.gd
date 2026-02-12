extends Control
class_name HeroHUD
signal pressed(index : int)

@onready var click_area: Button = $ClickArea
@onready var action: TextureRect = $Draw/HBoxContainer/Action
@onready var health_bar := $Draw/HBoxContainer/Detail/HealthBar
@onready var portrait: TextureRect = $Draw/HBoxContainer/Detail/Portrait
@onready var character_class: TextureRect = $Draw/HBoxContainer/Detail/Portrait/MarginContainer/Class
@onready var a: CanvasGroup = $Draw

func focusable(value : bool) -> void:
	if !value:
		focus_mode = Control.FOCUS_NONE
		click_area.focus_mode = Control.FOCUS_NONE
	else:
		focus_mode = Control.FOCUS_ALL
		click_area.focus_mode = Control.FOCUS_ALL

func _ready() -> void:
	size = $Draw/HBoxContainer.size
	click_area.size = size

func _on_focus_entered() -> void:
	if click_area.focus_mode == Control.FOCUS_NONE:
		click_area.focus_mode = Control.FOCUS_ALL
	click_area.call_deferred("grab_focus")

func _on_button_pressed() -> void:
	pressed.emit(get_index())
