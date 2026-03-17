@tool
extends EntityComponent
class_name StatsComponent

func _init() -> void:
	type = Type.STATS

signal health_changed(current: int, max_hp: int)

@export var base_stats : Dictionary = {
	"HP": 20,
	"ATK": 5,
	"DEF": 2,
	"SPD": 5
}

var live : Dictionary = {}

func initialize() -> void:
	for stat in base_stats:
		live[stat] = base_stats[stat]
		if stat == "HP":
			live["CURR_HP"] = base_stats[stat]

func get_stat(stat_name: String) -> int:
	# base value
	var base = live.get(stat_name, 0)
	
	# gets any buffs we have on that specific stat
	var status = host.get_comp(EntityComponent.Type.STATUS)
	if status:
		return int(base + status.get_total_modifier(stat_name))
	
	return base

func modify_stat(stat_name: String, amount: int) -> void:
	if not live.has(stat_name): return
	
	live[stat_name] += amount
	
	match stat_name:
		"CURR_HP", "HP":
			live["CURR_HP"] = clamp(live["CURR_HP"], 0, live["HP"])
			health_changed.emit(live["CURR_HP"], live["HP"])
