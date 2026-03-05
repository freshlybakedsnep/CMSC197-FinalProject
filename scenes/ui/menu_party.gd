extends Control
class_name PartyMenu

signal hero_selected
signal party_ready

var hero_to_hud : Dictionary[Entity, HeroHUD] = {}
var selected_hero : Hero

func setup(nodes : Array[Entity]) -> void:
	for i in range(nodes.size()):
		var hud = get_child(i) as HeroHUD
		var hero : Entity = nodes[i]
		hero_to_hud.set(hero, hud)
		
		hud.portrait.texture = hud.portrait.texture.duplicate()
		hud.portrait.texture.atlas = hero.data.sprite
		hud.value.text = str(hero.data.stats["HEALTH"])
		hud.health.value = hero.data.stats["HEALTH"]
		hud.health.max_value = hero.data.stats["HEALTH_MAX"]
		
		hero.data.health_changed.connect(
			func(h, m): 
				hud.health.value = h
				hud.health.max_value = m
				hud.value.text = str(h))
		
		var j = (hero.data as HeroData).character_class
		var t = hero.data.stats["ELEMENT"]
		
		hud.character_class.texture = load("res://assets/jobs/El%skind%s.png" % [str(t+1), str(j+1)])
		hud.pressed.connect(func(): select_hero(hero as Hero))
		hero.entity_eliminated.connect(func(): hud.enabled(false))
		hud.show()

func select_hero(hero : Hero) -> void:
	if hero:
		selected_hero = hero
		hero_selected.emit(hero)

func enabled(toggle : bool) -> void:
	for hero in hero_to_hud:
		if hero.data.state == UnitData.State.NORMAL:
			hero_to_hud[hero].enabled(toggle)
			if toggle == false and selected_hero == hero:
				hero_to_hud[hero].a.self_modulate = Color(1,1,1)
	if toggle:
		call_deferred("focus_initial")

func focus_initial() -> void:
	if selected_hero:
		if (selected_hero.action == HeroData.ActionMode.NONE 
			and selected_hero.data.state == UnitData.State.NORMAL):
				hero_to_hud[(selected_hero as Entity)].grab_focus()
				return
	
	for hero in hero_to_hud:
		if (hero.action == HeroData.ActionMode.NONE 
		and hero.data.state == UnitData.State.NORMAL):
			hero_to_hud[hero].grab_focus()
			return
	
	party_ready.emit()
