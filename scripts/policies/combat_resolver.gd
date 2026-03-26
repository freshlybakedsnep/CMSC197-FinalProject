class_name CombatResolver

static func resolve_health_adjust (
	attacker: EntityData, 
	defender: EntityData,
	effect_data: Dictionary) -> Dictionary:
	
	var damage: float = effect_data["amount"]
	if not effect_data["is_damaging"]:
		damage *= -1.0
		return {
			"final": int(damage),
			"ignore_def": false,
			"type_mult": 1.0,
			"blocked": false
		}
	
	if not effect_data.get("ignore_def", false):
		var def_comp = defender.get_comp(EntityComponent.Type.STATS)
		if def_comp:
			var defense = def_comp.get_stat("DEF")
			var k = 100.0
			damage *= (k/ (k + defense))
	
	var type_mult := 1.0
	var atk_elem : ElementComponent = attacker.get_comp(EntityComponent.Type.ELEMENT)
	var def_elem : ElementComponent = defender.get_comp(EntityComponent.Type.ELEMENT)
	if atk_elem and def_elem:
		type_mult = def_elem.get_damage_mult(atk_elem.my_elem)
		damage *= type_mult
	
	# signals any triggers
	var blocked := false
	var def_status : StatusComponent = defender.get_comp(EntityComponent.Type.STATUS)
	var atk_status : StatusComponent = attacker.get_comp(EntityComponent.Type.STATUS)
	if def_status:  
		def_status.tick_hits(StatusComponent.Trigger.ON_DEFEND)
		if def_status.has_flag("DEFEND"):
			damage *= 0.5
		if def_status.has_flag("INVULNERABLE") and \
		not (atk_status.has_flag("PIERCE") or effect_data.get("piercing", false)) :
			damage *= 0
			blocked = true
	if atk_status: 
		atk_status.tick_hits(StatusComponent.Trigger.ON_ATTACK)
	var final_dmg = int(max(0 if blocked else 1, damage))
	
	return {
		"final": final_dmg,
		"ignore_def": effect_data.get("ignore_def", false),
		"type_mult": type_mult,
		"blocked": blocked
	}
