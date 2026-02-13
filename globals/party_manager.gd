extends Node
class_name Party

var party : Array[HeroData] = []
const MAX_PARTY_SIZE = 5

func add_member(hero : HeroData) -> bool:
	if hero in party or party.size() >= MAX_PARTY_SIZE:
		return false
	
	party.append(hero)
	return true

func remove_member(hero : HeroData) -> int:
	var index = party.find(hero)
	party.erase(hero)
	return index
