extends Control
class_name TargetMenu

signal target_selected

var selected_hero: Hero
var ability: Ability
var action: HeroData.ActionMode
var display_targets : Array[Entity]

@onready var back: Button = $Back
@onready var confirm: Button = $Confirm
var current_selection : Array[Entity]
var required_targets : int = 1

func setup(data: Dictionary) -> void:
	for attr in data:
		if attr in self:
			self.set(attr, data[attr])
	
	current_selection.clear()
	ability.lock_entities(selected_hero)
	display_targets = ability.determine_targets(selected_hero, ability).filter(
		func(x): return (x as Entity).targetable)
	required_targets = min(display_targets.size(), ability.target_count)
	
	var targets = selected_hero.current_target.duplicate()
	if selected_hero.intent:
		if (ability.target_mode != selected_hero.intent.target_mode):
			targets.clear()
	
	for i in display_targets.size():
		var unit = display_targets[i]
		var b : Button = unit.target_component
		
		if not b.focus_entered.is_connected(predict_outcome):
			b.focus_entered.connect(func(): predict_outcome(unit, true))
			b.focus_exited.connect(func(): predict_outcome(unit, false))
		
		if b.pressed.is_connected(selected_target):
			b.pressed.disconnect(selected_target)
		b.pressed.connect(selected_target.bind(unit))
		
		b.focus_neighbor_bottom = confirm.get_path()
		b.focus_neighbor_top = back.get_path()
		
		if (targets.has(unit) or
			ability.target_mode == Ability.TargetMode.AOE or
			ability.target_mode == Ability.TargetMode.RANDOM or 
			(ability.target_group == Ability.TargetGroup.SELF and
			unit == selected_hero)):
			unit.outline_me(true)
			current_selection.append(unit)
			predict_outcome(unit, true)
		else:
			predict_outcome(unit, false)
		
		if i > 0:
			var lb = display_targets[i-1].target_component
			b.set_focus_neighbor(SIDE_LEFT, lb.get_path())
			lb.set_focus_neighbor(SIDE_RIGHT, b.get_path())
		
		if display_targets.size() > 1:
			var lb = display_targets[-1].target_component
			var fb = display_targets[0].target_component
			lb.set_focus_neighbor(SIDE_RIGHT, fb.get_path())
			fb.set_focus_neighbor(SIDE_LEFT, lb.get_path())
	
	if display_targets:
		back.focus_neighbor_bottom = display_targets.front().target_component.get_path()
		confirm.focus_neighbor_top = display_targets.front().target_component.get_path()
	
	ability.simulate(selected_hero)
	confirm_button()

func confirm_button() -> void:
	match ability.target_mode:
		Ability.TargetMode.AOE, Ability.TargetMode.RANDOM:
			confirm.disabled = false
			confirm.grab_focus()
		Ability.TargetMode.SINGLE, Ability.TargetMode.MULTIPLE:
			confirm.disabled = (current_selection.size() < required_targets)
	
	if current_selection.size() >= required_targets:
		confirm.grab_focus()

func predict_outcome(unit: Entity, shown: bool) -> void:
	if not shown:
		if (ability.target_mode != Ability.TargetMode.AOE and
		!current_selection.has(unit)):
			unit.hp_bar.clear_prediction()
			return
	
	if ability.target_mode == Ability.TargetMode.RANDOM:
		unit.hp_bar.clear_prediction()
		return
	unit.hp_bar.call_deferred("display_prediction")

func enabled(toggled : bool) -> void:
	visible = toggled
	RenderingServer.global_shader_parameter_set("screen_dim_amount", 
	0.3 if toggled else 1.0)
	selected_hero.highlight_me(toggled)
	
	for t in display_targets:
		t.hp_bar.visible = toggled
		t.target_component.visible = toggled
		t.sprite.material.set_shader_parameter("is_bright", toggled)
		if not toggled: t.outline_me(false)
	if toggled:
		call_deferred("focus_initial")

func focus_initial() -> void:
	if current_selection.size() >= required_targets:
		confirm.grab_focus()
		return
	
	for u in selected_hero.current_target:
		if display_targets.has(u):
			u.target_component.grab_focus()
			return
	
	if display_targets:
		display_targets[0].target_component.grab_focus()
	else:
		back.grab_focus()

func selected_target(unit: Entity) -> void:
	match ability.target_mode:
		Ability.TargetMode.AOE, Ability.TargetMode.RANDOM:
			return
		Ability.TargetMode.SINGLE, Ability.TargetMode.MULTIPLE:
			if current_selection.has(unit):
				current_selection.erase(unit)
				unit.outline_me(false)
			else:
				if ability.target_mode == Ability.TargetMode.SINGLE:
					for u in current_selection: 
						u.outline_me(false)
						u.hp_bar.clear_prediction()
					current_selection.clear()
				
				if current_selection.size() < required_targets:
					current_selection.append(unit)
					unit.outline_me(true)
	back.focus_neighbor_bottom = unit.target_component.get_path()
	confirm.focus_neighbor_top = unit.target_component.get_path()
	confirm_button()

func confirm_selection() -> void:
	selected_hero.set_target(current_selection)
	selected_hero.set_intent(action)
	target_selected.emit()
