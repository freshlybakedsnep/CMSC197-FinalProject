class_name ActionParser
static var damage_text : PackedScene = preload("res://scenes/stage_prelim/ui/damage_text.tscn")
static var effect_text : PackedScene = preload("res://scenes/stage_prelim/ui/effect_text.tscn")

static func execute(src: Entity, action: Action, targets: Array[EntityData] = []) -> void:
	var curr_action := action
	var main_targets : Array[EntityData] = targets
	
	var status : StatusComponent = src.data.get_comp(EntityComponent.Type.STATUS)
	var act : ActionComponent = src.data.get_comp(EntityComponent.Type.ACTION)
	var res : ResourceComponent = src.data.get_comp(EntityComponent.Type.RESOURCE)
	if act:
		# start cooldown and apply cost
		act.start_cooldown(curr_action)
		if res:
			res.consume(curr_action.cost)
			
		# defaults the action if SILENCED
		if status and status.has_flag("SILENCE") and action not in act.basic_pool:
			curr_action = act.basic_pool.pick_random()
			
			# removes all incompatible targets
			var valid_tar = BattleRegistry.get_potential_targets(src.data, curr_action.target_group)
			main_targets = main_targets.filter(func(t): return t in valid_tar)
			
			# randomly remove until within max target count
			while main_targets.size() > curr_action.target_count:
				main_targets.erase(main_targets.pick_random())
		
		if main_targets.is_empty():
			main_targets = TargetingResolver.get_targets(
				src.data, 
				curr_action.target_group, 
				curr_action.target_mode, 
				curr_action.target_count, 
				curr_action.target_state)
		
		var current_targets = main_targets
		for group in curr_action.effect_groups:
			current_targets = TargetingResolver.get_effect_targets(src.data, group, main_targets)
			
			if current_targets.is_empty(): continue
			
			for fx in group.effects:
				# insert animation code here
				
				for target in current_targets:
					_apply_effect(src.data, target, fx, action.level)
					
					#var tar_node = BattleRegistry.get_entity(target)
					#if tar_node:
						#tar_node.play_hit_vfx()
				
				await src.get_tree().create_timer(0.3).timeout
	src.entity_action_over.emit()

static func _apply_effect(src: EntityData, tar: EntityData, fx: Effect, level: int) -> void:
	var eff = fx.get_effect_data(src, tar, level)
	var stats : StatsComponent = tar.get_comp(EntityComponent.Type.STATS)
	var t
	match eff.get("type"):
		"HEALTH":
			var result = CombatResolver.resolve_health_adjust(src, tar, eff)
			stats.modify_stat("CURR_HP", -result["final_dmg"])
			
			t = damage_text.instantiate() as DamageText
			t.modify(result, eff.get("is_damaging"))
			
			if stats.get_stat("CURR_HP") <= 0:
				tar.host.entity_eliminated.emit()
		
		"STATUS":
			if tar.state != EntityData.State.DEAD and stats.get_stat("CURR_HP") > 0:
				var status = tar.get_comp(EntityComponent.Type.STATUS)
				if status:
					status.add_modifier(eff["key"], eff["params"])
				t = effect_text.instantiate() as EffectText
				t.effect(eff["key"], Color.WHITE, eff["params"].get("is_buff", true))
	tar.host.add_child(t)
	await t.finished
