class_name TargetingResolver

static func get_targets(src: EntityData, grp: int, mode: int, count: int, state: int) -> Array[EntityData]:
	var pool: Array[EntityData] = BattleRegistry.get_potential_targets(src, grp)
	
	# only return living targets as of the action
	match state:
		Action.TargetState.ALIVE:
			pool = pool.filter(func(u): return u.state != EntityData.State.DEAD)
		Action.TargetState.DEAD:
			pool = pool.filter(func(u): return u.state == EntityData.State.DEAD)
	
	# gets the list of provokers and notes them
	var provokers : Array[EntityData] = []
	if mode != Action.TargetMode.AOE:
		var status : StatusComponent = src.get_comp(EntityComponent.Type.STATUS)
		if status and status.is_provoked():
			# filters targets that are not in the action's scope
			provokers = status.get_provokers().filter(func(x): return x in pool)
		# checks if any enemy has a taunt on
		elif grp == Action.TargetGroup.ENEMY:
			provokers = pool.filter(
				func(x): 
				var xstat : StatusComponent = x.get_comp(EntityComponent.Type.STATUS)
				return xstat != null and xstat.has_taunt()
				)
	
	match mode:
		Action.TargetMode.SINGLE:
			if not provokers.is_empty():
				return provokers
			return pool
		Action.TargetMode.AOE:
			return pool
		Action.TargetMode.MULTIPLE, Action.TargetMode.RANDOM:
			var f_pool = provokers if not provokers.is_empty() else pool
			f_pool.shuffle()
			return f_pool.slice(0, min(f_pool.size(), count))
	return []

static func get_effect_targets(
	src: EntityData, efg: EffectGroup, 
	prev_targets: Array[EntityData]) -> Array[EntityData]: 
	
	if efg.inherit_target:
		return prev_targets
	
	return get_targets(src, efg.target_group, efg.target_mode, efg.target_count, efg.target_state)
