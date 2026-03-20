extends Button
class_name SkillButton

@onready var skill_icon: TextureRect = $SkillIcon
@onready var indicator: Label = $Indicator

func set_icon(icon_tex: Texture2D) -> void:
	if icon_tex:
		skill_icon.texture = icon_tex

func disable_button(toggle: bool, display: String = "") -> void:
	disabled = toggle
	indicator.visible = toggle
	indicator.text = display
