@tool
extends EntityComponent
class_name ActionComponent

func _init() -> void:
	type = Type.ACTION

enum Slot { BASIC, GUARD, SKILL_1, SKILL_2, ULTIMATE} 
@export var binds : Dictionary[Slot, Action] = {
	Slot.BASIC: null,
	Slot.GUARD: null,
	Slot.SKILL_1: null,
	Slot.SKILL_2: null,
	Slot.ULTIMATE: null
}

var cooldowns : Dictionary[Action, int] = {}

@export var basic_pool : Array[Action] = []
@export var skill_pool : Array[Action] = []
@export var ultimates : Array[Action] = []

func get_action(slot: Slot) -> Action:
	return binds.get(slot)

func get_slot(action: Action) -> Slot:
	return binds.find_key(action)

func get_priority(action: Action) -> int:
	if action == null: return 0
	if get_slot(action) == Slot.GUARD: return 100
	return action.priority

func is_on_cooldown(action: Action) -> bool:
	return cooldowns.get(action, 0) > 0

func get_duration_left(action: Action) -> int:
	return cooldowns.get(action, 0)

func tick_cooldowns() -> void:
	for a in cooldowns.keys():
		var new_val = max(0, cooldowns[a]-1)
		if new_val == 0:
			cooldowns.erase(a)
		else:
			cooldowns[a] = new_val

func start_cooldown(action: Action) -> void:
	cooldowns[action] = action.cooldown
