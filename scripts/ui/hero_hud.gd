extends Control
class_name HeroHUD
signal pressed(index : int)

@onready var click_area: Button = $ClickArea
@onready var health_bar := $Draw/Padding/Detail/HealthBar
@onready var portrait: TextureRect = $Draw/Padding/Detail/Portrait
@onready var character_class: TextureRect = $Draw/Padding/Detail/Portrait/MarginContainer/Class
@onready var a: CanvasGroup = $Draw

func focusable(value : bool) -> void:
	if !value:
		focus_mode = Control.FOCUS_NONE
		click_area.focus_mode = Control.FOCUS_NONE
	else:
		focus_mode = Control.FOCUS_ALL
		click_area.focus_mode = Control.FOCUS_ALL

func _ready() -> void:
	size = $Draw/Padding/Detail.size
	click_area.size = size

func _on_focus_entered() -> void:
	if click_area.focus_mode == Control.FOCUS_NONE:
		click_area.focus_mode = Control.FOCUS_ALL
	click_area.call_deferred("grab_focus")

func _on_button_pressed() -> void:
	pressed.emit(get_index())

func enabled(toggled : bool) -> void:
	if toggled:
		a.self_modulate = Color(1,1,1)
		focusable(true)
		mouse_behavior_recursive = MOUSE_BEHAVIOR_ENABLED
	else:
		a.self_modulate = Color(0.3,0.3,0.3)
		focusable(false) 
		mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED

func disable(_x : Object) -> void:
	enabled(false)
