extends Control
class_name PartyMenu

signal hero_selected
signal party_ready

var hero_to_hud : Dictionary[Entity, HeroHUD] = {}
var selected_hero : Entity

func setup(nodes : Array[Entity]) -> void:
	for i in range(nodes.size()):
		var hud = get_child(i) as HeroHUD
		var hero : Entity = nodes[i]
		hero_to_hud.set(hero, hud)
		
		hud.portrait.texture = hud.portrait.texture.duplicate()
		hud.portrait.texture.atlas = hero.data.sprite
		
		var stats : StatsComponent = hero.data.get_comp(EntityComponent.Type.STATS)
		if stats:
			hud.value.text = str(stats.get_stat("CURR_HP"))
			hud.health.value = stats.get_stat("CURR_HP")
			hud.health.max_value = stats.get_stat("HP")
		
			stats.health_changed.connect(
				func(h, m): 
					hud.health.value = h
					hud.health.max_value = m
					hud.value.text = str(h))
		
		var elem : ElementComponent = hero.data.get_comp(EntityComponent.Type.ELEMENT)
		
		if elem:
			var e = elem.my_elem
			var j = (hero.data as HeroData).character_class
			hud.character_class.texture = load("res://assets/jobs/El%skind%s.png" % [str(e+1), str(j+1)])
			hud.pressed.connect(func(): select_hero(hero))
			hero.entity_eliminated.connect(func(): hud.enabled(false))
		hud.show()

func select_hero(hero : Entity) -> void:
	if hero:
		selected_hero = hero
		hero_selected.emit(hero)

func enabled(toggle : bool) -> void:
	for hero in hero_to_hud:
		match hero.data.state:
			EntityData.State.NORMAL:
				hero_to_hud[hero].enabled(toggle)
				if toggle == false and selected_hero == hero:
					hero_to_hud[hero].a.self_modulate = Color(1,1,1)
	if toggle:
		call_deferred("focus_initial")

func focus_initial() -> void:	
	if selected_hero:
		if needs_action(selected_hero):
			hero_to_hud.get(selected_hero).grab_focus()
			return
		
	for hero in hero_to_hud:
		if needs_action(hero):
			hero_to_hud[hero].grab_focus()
			return
	
	party_ready.emit()

func needs_action(ent : Entity) -> bool:
	if ent:
		var status : StatusComponent = ent.data.get_comp(EntityComponent.Type.STATUS)
		var cont : PlayerController = ent.data.get_comp(EntityComponent.Type.CONTROLLER)
		if cont and status:
			# checks if they have no action set and if they can act at all
			if not cont.queued_action and not status.has_flag("STUN"):
				return true
	return false
