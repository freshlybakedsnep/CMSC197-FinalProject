extends Control
signal cancel_op
signal finish_op
var hero : Entity

func link_member(member : Entity) -> void:
	hero = member

func setup(targets : Array[Entity]) -> void:
	for unit in targets:
		var b = Button.new()
		b.text = str(unit.character_data.entity_name)
		b.set_meta("unit", unit)
		add_child(b)
		b.connect("pressed", selected_target.bind(unit))

func focus_initial() -> void:
	if hero.current_target.size() == 1:
		for b in get_children():
			if b.has_meta("unit"):
				if b.get_meta("unit") == hero.current_target[0]:
					b.grab_focus()
					return
	
	if get_child_count() > 1:
		get_child(1).grab_focus()
	else:
		get_child(0).grab_focus()

func selected_target(unit : Entity) -> void:
	hero.set_target(unit)
	finish_op.emit()

func _on_back_pressed() -> void:
	cancel_op.emit()
