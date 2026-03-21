extends Control
class_name TargetMenu

signal target_selected

var selected_hero: Entity
var action: Action
var slot: ActionComponent.Slot
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
	display_targets.clear()
	
	var dat = TargetingResolver.get_targets(
		selected_hero.data, 
		action.target_group,
		action.target_mode if action.target_mode < Action.TargetMode.AOE else Action.TargetMode.AOE,
		action.target_count,
		action.target_state)
	
	for d in dat:
		if d.state == action.target_state:
			var ent : Entity = BattleRegistry.get_entity(d)
			if ent:
				display_targets.append(ent)
	# calls policies to determine the scope
	required_targets = min(display_targets.size(), action.target_count)
	
	# gets the hero's previous targets
	var cont : PlayerController = selected_hero.data.get_comp(EntityComponent.Type.CONTROLLER)
	# checks if queued action is the same as the selected action
	var que = cont.queued_targets if cont.queued_action == action else []
	
	print(display_targets)
	
	for i in display_targets.size():
		var unit = display_targets[i]
		var b : Button = unit.target_component
		
		#if not b.focus_entered.is_connected(predict_outcome):
			#b.focus_entered.connect(func(): predict_outcome(unit, true))
			#b.focus_exited.connect(func(): predict_outcome(unit, false))
		for con in b.pressed.get_connections():
			b.pressed.disconnect(con["callable"])
		b.pressed.connect(selected_target.bind(unit))
		
		b.focus_neighbor_bottom = confirm.get_path()
		b.focus_neighbor_top = back.get_path()
		
		if (que.has(unit.data) or
			action.target_mode >= Action.TargetMode.AOE or
			(action.target_group == Action.TargetGroup.SELF and 
			unit == selected_hero)):
			unit.outline_me(true)
			current_selection.append(unit)
			#predict_outcome(unit, true)
		#else:
			#predict_outcome(unit, false)
		
		
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
	
	confirm_button()

func confirm_button() -> void:
	match action.target_mode:
		Action.TargetMode.AOE, Action.TargetMode.RANDOM:
			confirm.disabled = false
			confirm.grab_focus()
		Action.TargetMode.SINGLE, Action.TargetMode.MULTIPLE:
			confirm.disabled = (current_selection.size() < required_targets)
	
	if current_selection.size() >= required_targets:
		confirm.grab_focus()

#func predict_outcome(unit: Entity, shown: bool) -> void:
	#if not shown:
		#if (ability.target_mode != Ability.TargetMode.AOE and
		#!current_selection.has(unit)):
			#unit.hp_bar.clear_prediction()
			#return
	#
	#if ability.target_mode == Ability.TargetMode.RANDOM:
		#unit.hp_bar.clear_prediction()
		#return
	#unit.hp_bar.call_deferred("display_prediction")

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
	
	var cont: PlayerController = selected_hero.data.get_comp(EntityComponent.Type.CONTROLLER)
	if cont:
		for u in cont.queued_targets:
			if display_targets.has(u.host):
				u.target_component.grab_focus()
				return
	
	if display_targets:
		display_targets[0].target_component.grab_focus()
	else:
		back.grab_focus()

func selected_target(unit: Entity) -> void:
	match action.target_mode:
		Action.TargetMode.AOE, Action.TargetMode.RANDOM:
			return
		Action.TargetMode.SINGLE, Action.TargetMode.MULTIPLE:
			if current_selection.has(unit):
				current_selection.erase(unit)
				unit.outline_me(false)
			else:
				if action.target_mode == Action.TargetMode.SINGLE:
					for u in current_selection: 
						u.outline_me(false)
						#u.hp_bar.clear_prediction()
					current_selection.clear()
				
				if current_selection.size() < required_targets:
					current_selection.append(unit)
					unit.outline_me(true)
	back.focus_neighbor_bottom = unit.target_component.get_path()
	confirm.focus_neighbor_top = unit.target_component.get_path()
	confirm_button()

func confirm_selection() -> void:
	var cont : PlayerController = selected_hero.data.get_comp(EntityComponent.Type.CONTROLLER)
	if cont:
		var targets : Array[EntityData] = []
		
		if action.target_mode != Action.TargetMode.RANDOM:
			for node in current_selection:
				targets.append(node.data)
		cont.queued_action = action
		cont.queued_targets = targets 
	
	target_selected.emit()
