extends Control
class_name ActionMenu

signal action_selected

var back : Button
var selected_hero : Entity
var binds : Dictionary[ActionComponent.Slot, SkillButton] = {
	ActionComponent.Slot.BASIC : null,
	ActionComponent.Slot.GUARD : null,
	ActionComponent.Slot.SKILL_1 : null,
	ActionComponent.Slot.SKILL_2 : null,
	ActionComponent.Slot.ULTIMATE : null
}

func add_back(b : Button) -> void:
	back = b

func _ready() -> void:
	for i in range(binds.size()):
		var butt : SkillButton = get_child(i) as SkillButton
		var slot : ActionComponent.Slot = binds.keys()[i]
		binds.set(slot, butt)
		butt.pressed.connect(func(): select_action(slot))

func load_menu(hero : Entity) -> void:
	selected_hero = hero
	var act_sys : ActionComponent = selected_hero.data.get_comp(EntityComponent.Type.ACTION)
	var status : StatusComponent = selected_hero.data.get_comp(EntityComponent.Type.STATUS)
	var res : ResourceComponent = selected_hero.data.get_comp(EntityComponent.Type.RESOURCE)
	if !act_sys: return
	var silenced = status.has_flag("SILENCE")
	for slot in binds:
		var action : Action = act_sys.get_action(slot)
		var button := binds[slot]
		if action == null:
			button.hide()
			continue
		
		button.set_icon(action.action_icon)
		if act_sys.basic_pool.has(action):
			continue
		
		if silenced:
			button.disable_button(true, "X")
			continue
		if act_sys.is_on_cooldown(action):
			button.disable_button(true, str(act_sys.get_duration_left(action)))
			continue
		
		if res:
			if res.current_amount < action.cost:
				button.disable_button(true)
				continue
		
		button.disable_button(false)

func select_action(slot: ActionComponent.Slot) -> void:
	if selected_hero:
		action_selected.emit(slot)

func enabled(toggled : bool) -> void:
	back.visible = toggled
	for slot in binds:
		var skill_button = binds[slot]
		skill_button.modulate.a = 1.0 if toggled else 0.7
		skill_button.focus_mode = FOCUS_ALL if toggled else FOCUS_NONE
		skill_button.mouse_behavior_recursive = MOUSE_BEHAVIOR_ENABLED if toggled else MOUSE_BEHAVIOR_DISABLED
	if toggled:
		call_deferred("focus_initial")

func focus_initial() -> void:
	if not is_visible_in_tree(): return
	
	var act_sys : ActionComponent = selected_hero.data.get_comp(EntityComponent.Type.ACTION)
	var cont : PlayerController = selected_hero.data.get_comp(EntityComponent.Type.CONTROLLER)
	var slot = ActionComponent.Slot.BASIC
	if act_sys and cont and cont.queued_action:
		slot = act_sys.get_slot(cont.queued_action)
		if slot == null:
			slot = ActionComponent.Slot.BASIC
	binds[slot].grab_focus()
