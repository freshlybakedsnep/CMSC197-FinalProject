extends VBoxContainer
signal open_skill_menu
signal cancel_op
signal finish_op

var hero : Entity
var select := 1

func enable() -> void:
	modulate.a = 1.0
	for b in get_children():
		b.modulate.a = 1.0
		b.focus_mode = FOCUS_ALL
		b.mouse_behavior_recursive = MOUSE_BEHAVIOR_ENABLED

func disable() -> void:
	modulate.a = 0.7
	for b in get_children():
		b.focus_mode = FOCUS_NONE
		b.mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED

func focus_initial() -> void:
	if hero.current_action == UnitData.ActionMode.NONE:
		get_child(select).grab_focus()
	else:
		get_child(min(hero.current_action, 3)).grab_focus()

func link_member(member : Entity) -> void:
	hero = member

func select_action(i : int) -> void:
	select = i
	if i > 2 :
		var c = get_children()
		c.remove_at(i)
		for m in c:
			m.modulate.a = 0.2
		open_skill_menu.emit()
	else:
		if i > 0:
			hero.current_action = i as UnitData.ActionMode
			finish_op.emit()
		else:
			cancel_op.emit()
