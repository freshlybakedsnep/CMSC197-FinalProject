extends Control
signal cancel_op
signal finish_op

var hero : Entity
var display_targets : Array[Entity]
@onready var back: Button = $Back

func link_member(member : Entity) -> void:
	hero = member

func setup(targets : Array[Entity]) -> void:
	RenderingServer.global_shader_parameter_set("screen_dim_amount", 0.3)
	
	display_targets = targets.filter(func(x): return (x as Entity).targetable)
	hero.highlight_me(true)
	
	for i in display_targets.size():
		var unit = display_targets[i]
		unit.hp_bar.show()
		unit.target_component.is_selectable = true
		unit.target_component.show()
		unit.sprite.material.set_shader_parameter("is_bright", true)
	
		var b = unit.target_component.proxy
		b.connect("pressed", selected_target.bind(unit))
		if i > 0:
			var lb = display_targets[i-1].target_component.proxy
			b.set_focus_neighbor(SIDE_LEFT, lb.get_path())
			lb.set_focus_neighbor(SIDE_RIGHT, b.get_path())
		
		if display_targets.size() > 1:
			var fb = display_targets[0].target_component.proxy
			var lb = display_targets[-1].target_component.proxy
			fb.set_focus_neighbor(SIDE_LEFT, lb.get_path())
			lb.set_focus_neighbor(SIDE_RIGHT, fb.get_path())
		
		b.set_focus_neighbor(SIDE_TOP, back.get_path())
	
	if display_targets:
		back.set_focus_neighbor(SIDE_BOTTOM, targets[0].target_component.proxy.get_path())
		back.set_focus_neighbor(SIDE_RIGHT, targets[0].target_component.proxy.get_path())
		back.set_focus_neighbor(SIDE_LEFT, targets[-1].target_component.proxy.get_path())

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
	RenderingServer.global_shader_parameter_set("screen_dim_amount", 1.0)
	hero.highlight_me(false)
	for c in display_targets:
		c.hp_bar.hide()
		c.target_component.hide()
		c.target_component.is_selectable = false
		c.sprite.material.set_shader_parameter("is_bright", false)

func selected_target(unit : Entity) -> void:
	hero.set_target(unit)
	finish_op.emit()
	exit_menu()

func _on_back_pressed() -> void:
	cancel_op.emit()
	exit_menu()
