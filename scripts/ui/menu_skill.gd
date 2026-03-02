extends Control
signal cancel_op
signal finish_op

var hero : Entity

func enable() -> void:
	modulate.a = 1.0
	for b in get_children():
		b.modulate.a = 1.0
		b.focus_mode = FOCUS_ALL
		b.mouse_behavior_recursive = MOUSE_BEHAVIOR_ENABLED

func disable() -> void:
	for b in get_children():
		b.focus_mode = FOCUS_NONE
		b.mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED
	modulate.a = 0.5

func focus_initial() -> void:
	if hero.current_action == UnitData.ActionMode.NONE:
		get_child(1).grab_focus()
	else:
		get_child(max(hero.current_action-2, 1)).grab_focus()

func link_member(member : Entity) -> void:
	hero = member

func select_action(i : int) -> void:
	if i == 0:
		cancel_op.emit()
		return
	
	hero.current_action = i + 2 as UnitData.ActionMode
	
	var c = get_children()
	c.remove_at(i)
	for m in c:
		m.modulate.a = 0.5
	finish_op.emit()
