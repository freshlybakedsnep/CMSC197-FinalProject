class_name TargetingResolver

static func get_targets(src: EntityData, grp: int, mode: int, count: int, state: int) -> Array[EntityData]:
	var pool: Array[EntityData] = BattleRegistry.get_potential_targets(src, grp)
	
	# only return living targets as of the action
	match state:
		Action.TargetState.ALIVE:
			pool = pool.filter(func(u): return u.state != EntityData.State.DEAD)
		Action.TargetState.DEAD:
			pool = pool.filter(func(u): return u.state == EntityData.State.DEAD)
	
	# gets the list of candidate targets and notes them
	var candidates : Array[EntityData] = []
	if mode != Action.TargetMode.AOE:
		var status : StatusComponent = src.get_comp(EntityComponent.Type.STATUS)
		
		# Priority 1: PROVOKE DEBUFF
		if status and status.is_provoked():
			# gets targets and filters out that aren't in the action's scope
			candidates = status.get_provokers().filter(func(x): return x in pool)
		
		# Priority 2: TAUNT BUFF
		elif grp == Action.TargetGroup.ENEMY:
			candidates = pool.filter(
				func(x): 
				var xstat : StatusComponent = x.get_comp(EntityComponent.Type.STATUS)
				return xstat != null and xstat.has_taunt()
				)
		
	match mode:
		Action.TargetMode.SINGLE:
			if not candidates.is_empty():
				return _get_targetable(src, candidates)
			return _get_targetable(src, pool)
		Action.TargetMode.AOE:
			return pool
		Action.TargetMode.MULTIPLE, Action.TargetMode.RANDOM:
			var f_pool = candidates if not candidates.is_empty() else pool
			f_pool = _get_targetable(src, f_pool)
			f_pool.shuffle()
			return f_pool.slice(0, min(f_pool.size(), count))
	return []

static func _get_targetable(src: EntityData, candidates: Array[EntityData]):
	var valid = candidates.filter(func(tar):
		if src.faction == tar.faction:
			return true
		
		var stat : StatusComponent = tar.get_comp(EntityComponent.Type.STATUS)
		return stat and stat.is_targetable()
		)
	return valid if not valid.is_empty() else candidates
	
static func get_effect_targets(
	src: EntityData, efg: EffectGroup, 
	prev_targets: Array[EntityData]) -> Array[EntityData]: 
	
	if efg.inherit_target:
		return prev_targets
	
	return get_targets(src, efg.target_group, efg.target_mode, efg.target_count, efg.target_state)
