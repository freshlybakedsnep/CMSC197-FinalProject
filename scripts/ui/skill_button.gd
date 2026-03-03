extends Button
class_name SkillButton

@onready var skill_icon: TextureRect = $SkillIcon
@onready var cooldown: Label = $Cooldown

func set_assets(icon_tex : Texture2D = null, turns_left: int = 0) -> void:
	text = name
	if icon_tex:
		skill_icon.texture = icon_tex
	disabled = false
	cooldown.text = str("")
	if turns_left > 0:
		cooldown.text = str(turns_left)
		disabled = true
