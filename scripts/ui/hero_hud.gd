extends Button
class_name HeroHUD

@onready var health: ProgressBar = $Draw/Margin/Detail/Health
@onready var value: Label = $Draw/Margin/Detail/Health/Value
@onready var portrait: TextureRect = $Draw/Margin/Detail/Portrait
@onready var a: CanvasGroup = $Draw
@onready var character_class: TextureRect = $Draw/Margin/Detail/Portrait/MarginContainer/Class

func enabled(toggle : bool) -> void:
	a.self_modulate = Color(1,1,1) if toggle else Color(0.3,0.3,0.3)
	disabled = false if toggle else true
	focus_mode = Control.FOCUS_ALL if toggle else Control.FOCUS_NONE
	mouse_behavior_recursive = MOUSE_BEHAVIOR_ENABLED if toggle else MOUSE_BEHAVIOR_DISABLED
