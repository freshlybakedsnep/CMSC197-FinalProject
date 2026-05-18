extends EntityFormation
class_name HeroFormation

func setup(death_row : Array) -> void:
	super.setup(death_row)
	
	for i in PartyManager.party.size():
		var hero_res = PartyManager.party[i]
		if hero_res == null: continue
		
		var hero_node = spawn_entity(hero_res, true)
		hero_node.add_to_group("heroes")
		hero_node.data.faction = EntityData.Faction.HERO
		formation[i+1] = hero_node
		_positions[i+1].add_child(hero_node)

func wiped() -> bool:
	var active = formation.values().filter(func(h): return h)
	return active.filter(func(h): return h.data.state == EntityData.State.NORMAL).is_empty()
