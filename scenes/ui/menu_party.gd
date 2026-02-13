extends VBoxContainer 
signal actor_selected(index : int)
signal party_ready

var hero_nodes : Array[Entity]

@onready var party: Array = $".".get_children()
var actor : int

func setup(nodes : Array[Entity]) -> void:
	for i in party:
		i.hide()
		
	hero_nodes = nodes

	for i in range(hero_nodes.size()):
		party[i].show()
		party[i].portrait.texture = party[i].portrait.texture.duplicate()
		party[i].portrait.texture.atlas = hero_nodes[i].character_data.sprite
		party[i].health_bar.update_health(hero_nodes[i].health, hero_nodes[i].character_data.base_health)
		var j = hero_nodes[i].character_data.character_class
		var t = hero_nodes[i].character_data.elemental_type
		party[i].character_class.texture = load("res://assets/jobs/El%skind%s.png" % [str(t+1), str(j+1)])
		party[i].pressed.connect(pick_actor)

func disable() -> void:
	for p in get_children():
		if p.get_index() != actor:
			p.a.self_modulate.a = 0.2
		p.focusable(false)
		p.mouse_behavior_recursive = MOUSE_BEHAVIOR_DISABLED

func enable() -> void:
	actor = 0
	for p in get_children():
		p.a.self_modulate.a = 1.0
		p.focusable(true)
		p.mouse_behavior_recursive = MOUSE_BEHAVIOR_ENABLED

func pick_actor(pos : int) -> void:
	actor = pos
	actor_selected.emit(pos)

func focus_initial() -> void:
	if hero_nodes[actor].current_action == UnitData.ActionMode.NONE:
		party[actor].grab_focus()
		return
	
	for member in range(hero_nodes.size()):
		if (hero_nodes[member].condition == UnitData.State.NORMAL and 
		hero_nodes[member].current_action == UnitData.ActionMode.NONE):
			party[member].grab_focus()
			return
	
	party_ready.emit()
