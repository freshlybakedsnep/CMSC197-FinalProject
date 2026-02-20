extends Control
signal cancel_op
signal finish_op

var hero : Entity
var display_targets : Array[Entity]
@onready var back: Button = $Back

func link_member(member : Entity) -> void:
	hero = member

func setup(targets : Array[Entity]) -> void:
	display_targets = targets
	
	for i in range(targets.size()):
		var unit = targets[i]
		var b = unit.target_component.proxy
		
		unit.target_component.visible = true
		unit.target_component.is_selectable = true
		unit.target_component.is_targetable(true)
		b.connect("pressed", selected_target.bind(unit))
		
		if i > 0:
			var lb = targets[i-1].target_component.proxy
			b.set_focus_neighbor(SIDE_LEFT, lb.get_path())
			lb.set_focus_neighbor(SIDE_RIGHT, b.get_path())
		
		if targets.size() > 1:
			var fb = targets[0].target_component.proxy
			var lb = targets[-1].target_component.proxy
			fb.set_focus_neighbor(SIDE_LEFT, lb.get_path())
			lb.set_focus_neighbor(SIDE_RIGHT, fb.get_path())
		
		b.set_focus_neighbor(SIDE_TOP, back.get_path())
	
	if targets:
		back.set_focus_neighbor(SIDE_BOTTOM, targets[0].target_component.proxy.get_path())

func focus_initial() -> void:
	if hero.current_target.size() == 1:
		var x = hero.current_target[0]
		if display_targets.has(x):
			var f = display_targets.find(x)
			display_targets[f].target_component.grab_focus()
		
	if display_targets.size() > 0:
		display_targets[0].target_component.grab_focus()
	else:
		back.grab_focus()

func exit_menu() -> void:
	for c in display_targets:
		c.target_component.visible = false
		c.target_component.is_targetable(false)
		c.target_component.is_selectable = false

func selected_target(unit : Entity) -> void:
	hero.set_target(unit)
	finish_op.emit()
	exit_menu()

func _on_back_pressed() -> void:
	cancel_op.emit()
	exit_menu()
