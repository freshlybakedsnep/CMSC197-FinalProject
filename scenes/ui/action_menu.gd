extends Control
class_name ActionMenu

signal action_selected

var back : Button
var selected_hero : Hero
var buttons : Dictionary[HeroData.ActionMode, SkillButton] = {
	HeroData.ActionMode.BASIC_ATTACK : null,
	HeroData.ActionMode.GUARD_ATTACK : null,
	HeroData.ActionMode.SKILL_SLOT1 : null,
	HeroData.ActionMode.SKILL_SLOT2 : null,
	HeroData.ActionMode.SKILL_EXTRA : null
}

func add_back(b : Button) -> void:
	back = b

func _ready() -> void:
	for i in range(buttons.size()):
		var butt : SkillButton = get_child(i) as SkillButton
		var action : HeroData.ActionMode = buttons.keys()[i]
		buttons.set(action, butt)
		butt.pressed.connect(func(): select_action(action))

func load_menu(hero : Entity) -> void:
	selected_hero = hero
	var dat = selected_hero.data as HeroData
	for i in buttons:
		var abil : Ability = dat.ability_preset.get(i)
		var skill_icon := abil.ability_icon
		var duration : int = abil.downtime
		buttons[i].set_assets(skill_icon, duration)

func select_action(action : HeroData.ActionMode) -> void:
	if selected_hero:
		action_selected.emit(action)

func enabled(toggled : bool) -> void:
	back.visible = toggled
	for butt in buttons:
		var b = buttons[butt]
		b.modulate.a = 1.0 if toggled else 0.7
		b.focus_mode = FOCUS_ALL if toggled else FOCUS_NONE
		b.mouse_behavior_recursive = MOUSE_BEHAVIOR_ENABLED if toggled else MOUSE_BEHAVIOR_DISABLED
	if toggled:
		call_deferred("focus_initial")

func focus_initial() -> void:
	if selected_hero.action == HeroData.ActionMode.NONE:
		buttons[HeroData.ActionMode.BASIC_ATTACK].grab_focus()
	else:
		buttons[selected_hero.action].grab_focus()
