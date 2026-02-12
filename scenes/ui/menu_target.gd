extends Control
signal cancel_op
signal finish_op
var hero : HeroData

func link_member(member : HeroData) -> void:
	hero = member

func setup(targets : Array) -> void:
	hero.target_range = targets
	for unit in targets:
		var b = Button.new()
		b.text = str(unit.entity_name)
		b.set_meta("unit", unit)
		add_child(b)
		b.connect("pressed", selected_target.bind(unit))

func focus_initial() -> void:
	var t = hero.target
	
	if t != null and not (t is Array):
		for b in get_children():
			if b.has_meta("unit"):
				if b.get_meta("unit") == hero.target:
					b.grab_focus()
					return
	
	if get_child_count() > 1:
		get_child(1).grab_focus()
	else:
		get_child(0).grab_focus()

func selected_target(unit) -> void:
	hero.target = unit
	finish_op.emit()

func _on_back_pressed() -> void:
	cancel_op.emit()
