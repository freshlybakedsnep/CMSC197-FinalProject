extends Node
class_name StageInfo

@export var waves : Array[Wave]
@onready var battle_ui: Control = $BattleUI

const MAX_ON_FIELD := 5

var on_field : Dictionary = {
	0 : null,
	1 : null,
	2 : null,
	3 : null,
	4 : null,
}

var wave_index := 0
var turn_count := 0

var turn_queue : Array
var acted : Array


var names : Dictionary

func _ready() -> void:
	PartyManager.load_party()
	start_turn()

func start_turn() -> void:
	initialize_enemy_formation()
	initialize_enemy_actions()
	update_turn_order()
	turn_count += 1
	start_phase_plan()

func initialize_enemy_formation() -> void:
	var f = 0
	var e = MAX_ON_FIELD
	
	while e > 0:
		var enemy = waves[wave_index].enemies.pop_front()
		if enemy == null : return
		enemy = enemy.duplicate()
		
		if names.keys().has(enemy.entity_name):
			names[enemy.entity_name] += 1
			enemy.entity_name += " " + char(64 + names[enemy.entity_name])
		else:
			names[enemy.entity_name] = 1
		
		var scouting = true
		if enemy.starting_position != EnemyData.Positions.ANY:
			var s = enemy.starting_position
			if on_field.get(s) == null:
				on_field[s] = enemy
				scouting = false
		
		if scouting:
			while on_field.get(f):
				f += 1
			on_field[f] = enemy
			f += 1
		
		enemy.initialize()
		e -= 1

func initialize_enemy_actions() -> void:
	for enemy in on_field.values():
		if enemy == null: continue
		enemy.charge += 1
		if enemy.charge > enemy.max_charges:
			enemy.charge = 0
		
		enemy.set_action()
		var e = enemy.get_current_ability()
		enemy.target_range = finalize_targets(e, enemy)
		enemy.set_target()

func update_turn_order() -> void:
	turn_queue.clear()
	
	var all_units = []
	all_units.append_array(PartyManager.party)
	for unit in on_field.values():
		if unit != null:
			all_units.append(unit)
	
	for unit in all_units:
		if not acted.has(unit):
			turn_queue.append(unit)
	
	turn_queue.sort_custom(
		func(a, b) : return a.speed > b.speed
	)

func start_phase_plan():
	print("Turn %d" % turn_count)
	#for f in on_field:
		#print("%s: %s" % [f, on_field[f].entity_name])
	battle_ui.turn_start(on_field)

func end_turn():
	acted.clear()
	start_turn()

func start_phase_fight() -> void:
	change_actor()

func change_actor() -> void:
	if turn_queue.is_empty():
		end_turn()
		return
	
	var current_actor = turn_queue.pop_front()
	enact(current_actor)

func enact(actor) -> void:
	var t = actor.target
	
	if t == null or (t is Object and is_instance_valid(t)):
		# retarget logic
		pass
	if t is Array:
		var temp = []
		for x in t:
			temp.append(x.entity_name)
		t = ", ".join(temp)
	else:
		t = t.entity_name
	print("%s uses %s on %s" % 
	[actor.entity_name, UnitData.ActionMode.find_key(actor.action), t])
	acted.append(actor)
	
	actor.action = UnitData.ActionMode.NONE
	actor.target = null
	actor.target_range = []
	
	update_turn_order()
	change_actor()

func finalize_targets(ability : Ability, unit : UnitData):
	var side = []
	if unit is HeroData:
		side.append_array(PartyManager.party)
	elif unit is EnemyData:
		side.append_array(on_field.values())

	match ability.target:
		Ability.TargetGroup.SELF:
			return [unit]
		Ability.TargetGroup.PARTY:
			return side
		Ability.TargetGroup.ALLY_ONLY:
			side.erase(unit)
			return side
		Ability.TargetGroup.ENEMY:
			if unit is HeroData:
				return on_field.values()
			else:
				return PartyManager.party
		_:
			return null
