extends Control
class_name TargetMenu

signal target_selected

var selected_hero : Hero
var display_targets : Array[Entity]
@onready var back: Button = $Back

func setup(hero : Hero, targets : Array[Entity], action : HeroData.ActionMode) -> void:
	selected_hero = hero
	display_targets = targets.filter(func(x): return (x as Entity).targetable)
	
	for i in display_targets.size():
		var unit = display_targets[i]
		var b = unit.target_component.proxy
		
		for connection in b.pressed.get_connections():
			b.pressed.disconnect(connection.callable)
		
		b.pressed.connect(selected_target.bind(unit, action))
		if i > 0:
			var lb = display_targets[i-1].target_component.proxy
			b.set_focus_neighbor(SIDE_LEFT, lb.get_path())
			lb.set_focus_neighbor(SIDE_RIGHT, b.get_path())
		
		if display_targets.size() > 1:
			var lb = display_targets[-1].target_component.proxy
			lb.set_focus_neighbor(SIDE_RIGHT, back.get_path())
	
	if display_targets:
		back.set_focus_neighbor(SIDE_LEFT, targets[-1].target_component.proxy.get_path())

func enabled(toggled : bool) -> void:
	visible = toggled
	RenderingServer.global_shader_parameter_set("screen_dim_amount", 
	0.3 if toggled else 1.0)
	selected_hero.highlight_me(toggled)
	
	for t in display_targets:
		t.hp_bar.visible = toggled
		t.target_component.visible = toggled
		t.target_component.is_selectable = toggled
		t.sprite.material.set_shader_parameter("is_bright", toggled)
	if toggled:
		call_deferred("focus_initial")

func focus_initial() -> void:
	if selected_hero.current_target.size() == 1:
		var x = selected_hero.current_target[0]
		if display_targets.has(x):
			var f = display_targets.find(x)
			display_targets[f].target_component.proxy.grab_focus()
		
	if display_targets.size() > 0:
		display_targets[0].target_component.proxy.grab_focus()

func selected_target(unit : Entity, action : HeroData.ActionMode) -> void:
	selected_hero.set_target(unit)
	selected_hero.set_intent(action)
	target_selected.emit()
