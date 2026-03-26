@tool
extends EntityComponent
class_name AIController

var queued_action : Action
var queued_targets : Array[EntityData] = []

var logic : AILogic

func _init() -> void:
	type = Type.CONTROLLER

func get_next_action() -> Dictionary:
	var act_sys = host.get_comp(EntityComponent.Type.ACTION)
	if not act_sys: return {}
	
	var chosen_action : Action = null
	var res = host.get_comp(Type.RESOURCE)
	if res and res.current_amount >= res.max_amount:
		chosen_action = act_sys.ultimates.pick_random()
	else:
		var pool : Array = act_sys.basic_pool + act_sys.skill_pool
		if not pool.is_empty():
			chosen_action = pool.pick_random()
	
	if chosen_action == null: return {}
	
	var pots = TargetingResolver.get_targets(
		host,
		chosen_action.target_group,
		chosen_action.target_mode,
		chosen_action.target_count,
		chosen_action.target_state
	)
	
	var targets : Array[EntityData]
	match chosen_action.target_mode:
		Action.TargetMode.SINGLE:
			targets = [pots.pick_random()]
		Action.TargetMode.AOE:
			targets = pots
		Action.TargetMode.RANDOM, Action.TargetMode.MULTIPLE:
			pots.shuffle()
			targets = pots.slice(0, min(pots.size(), chosen_action.target_count))
	
	return {
		&"action": chosen_action,
		&"targets": targets
	}

func clear_queue() -> void:
	queued_action = null
	queued_targets.clear()
