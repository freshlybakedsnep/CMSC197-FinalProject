@tool
extends EntityComponent
class_name StatusComponent

func _init():
	type = Type.STATUS

signal status_added(key: StringName)
signal status_removed(key: StringName)

var _active_status : Dictionary = {}
# 1st-level : buckets data based on special behavior
# 2nd-level : name of buff
# 3rd-level : property of buff

enum Trigger { ON_ATTACK, ON_DEFEND }

func add_modifier(stat_name: String, params: Dictionary) -> void:
	# Hard Block: don't refresh
	if params.get("unique", false) and has_flag(stat_name):
		return
	
	var behavior = params.get("behavior", StatusEffect.Behavior.NONE)
	if not _active_status.has(behavior):
		_active_status[behavior] = {}
	if not _active_status[behavior].has(stat_name):
		_active_status[behavior][stat_name] = []
	
	var bucket_list = _active_status[behavior][stat_name]
	
	# Soft Block: refresh if existing
	var new_id = params.get("id", "")
	if new_id != "":
		for item in bucket_list:
			if item.get("id") == new_id:
				item["turns"] = params["turns"]
				item["hits"] = params["hits"]
				return
	
	var data = {
		"turns": params.get("turns", 1),
		"hits": params.get("hits", 0),
		"hit-based": params.get("hit-based", false),
		"permanent": params.get("permanent", false),
		"removable": params.get("removable", true),
		"trigger_on": params.get("trigger_on", Trigger.ON_DEFEND),
		"val": params.get("val", 1),
		"caster": params.get("caster"),
	}
	bucket_list.append(data)
	status_added.emit(stat_name)

func get_total_modifier(stat_name: String) -> float:
	var total := 0.0
	for behavior in _active_status:
		var b = _active_status[behavior]
		if b.has(stat_name):
			for mod in b[stat_name]:
				total += mod["val"]
	return total

func has_flag(flag_name: String) -> bool:
	for behavior in _active_status:
		if _active_status[behavior].has(flag_name) \
		and not _active_status[behavior][flag_name].is_empty():
			return true
	return false

func _has_behavior(behavior: StatusEffect.Behavior, key: StringName = &"") -> bool:
	if not _active_status.has(behavior):
		return false
	if key == &"":
		return not _active_status[behavior].is_empty()
	return _active_status[behavior].has(key)

func is_incapacitated() -> bool:
	return _has_behavior(StatusEffect.Behavior.INCAPACITATE)

func is_provoked() -> bool:
	return _has_behavior(StatusEffect.Behavior.RESTRICT, &"PROVOKE")

func is_targetable() -> bool:
	return not _has_behavior(StatusEffect.Behavior.PROTECT, &"UNTARGETABLE")

func get_provokers() -> Array[EntityData]:
	var p : Array[EntityData] = []
	if is_provoked():
		for mod in _active_status[StatusEffect.Behavior.RESTRICT]["PROVOKE"]:
			var cas = mod.get("caster")
			if cas not in p:
				p.append(cas)
	return p

func has_taunt() -> bool:
	return not _has_behavior(StatusEffect.Behavior.PROTECT, &"TAUNT")

func tick_turns() -> void:
	_process_reduction("turns")

func tick_hits(trigger_type: Trigger) -> void:
	_process_reduction("hits", trigger_type)

func _process_reduction(key: String, trigger_type: Variant = null) -> void:
	# iterate through all buckets
	for behavior in _active_status.keys():
		var b = _active_status[behavior]
		# iterate through each stat
		for stat in b.keys():
			var listing = b[stat]
			# iterate through each instance
			for i in range(listing.size()-1, -1, -1):
				var mod = listing[i]
				match key:
					"hits" when mod["hits"] > 0 and mod["trigger_on"] == trigger_type:
						mod["hits"] -= 1
					"turns" when mod["turns"] > 0:
						mod["turns"] -= 1
				
				var turns_expired = (mod["turns"] == 0 and not mod["permanent"])
				var hits_expired = (mod["hits"] == 0 and mod["hit-based"])
				
				if mod["permanent"]: continue
				if turns_expired or hits_expired:
					# add a signal here for triggers of certain effects upon removal
					status_removed.emit(stat)
					listing.remove_at(i)
			if listing.is_empty():
				b.erase(stat)
		if b.is_empty():
			_active_status.erase(behavior)
