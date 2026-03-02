extends EntityFormation
class_name HeroManager

func setup(spawner : Callable) -> void:
	for i in PartyManager.party.size():
		var hero_res = PartyManager.party[i]
		if hero_res == null: continue
		
		var hero_node = spawner.call(hero_res)
		formation[i+1] = hero_node
		_positions[i+1].add_child(hero_node)
