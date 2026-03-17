@tool
extends EntityComponent
class_name PlayerController

var queued_action : Action
var queued_targets : Array[EntityData] = []

func _init() -> void:
	type = Type.CONTROLLER

func get_next_action() -> Dictionary:
	if queued_action == null:
		return {}
	return {
		"action": queued_action,
		"targets": queued_targets
	}

func select_action(slot: ActionComponent.Slot) -> bool:
	var act_sys = host.get_comp(Type.ACTION)
	if not act_sys: return false
	
	var chosen = act_sys.binds[slot]
	if chosen == null or act_sys.is_on_cooldown(chosen):
		print("Invalid")
		return false
	
	queued_action = chosen
	if queued_action.target_group == Action.TargetGroup.SELF:
		queued_targets = [host]
	return true

func clear_queue() -> void:
	queued_action = null
	queued_targets.clear()
