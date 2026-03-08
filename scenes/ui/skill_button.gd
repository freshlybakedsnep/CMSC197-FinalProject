extends Button
class_name SkillButton

@onready var skill_icon: TextureRect = $SkillIcon
@onready var indicator: Label = $Indicator

func set_assets(icon_tex : Texture2D = null, ind_text: String = "", toggle: bool = false) -> void:
	text = name
	if icon_tex:
		skill_icon.texture = icon_tex
	indicator.text = ind_text
	indicator.visible = toggle
	disabled = toggle
