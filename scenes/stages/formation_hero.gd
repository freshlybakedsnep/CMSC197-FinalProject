extends EntityFormation
class_name HeroFormation

func setup(callable : Callable, death_row : Array) -> void:
	for i in PartyManager.party.size():
		var hero_res = PartyManager.party[i]
		if hero_res == null: continue
		
		var hero_node = spawn_entity(hero_res)
		hero_node.add_to_group("heroes")
		formation[i+1] = hero_node
		_positions[i+1].add_child(hero_node)
		hero_node.entity_action_over.connect(callable)
		hero_node.entity_eliminated.connect(func(): death_row.append(hero_node))
