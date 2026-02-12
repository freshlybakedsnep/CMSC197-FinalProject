extends VBoxContainer 
signal actor_selected(index : int)
signal party_ready

@onready var party: Array = $".".get_children()
var actor : int

func _ready() -> void:
	for i in party:
		i.hide()
		
	for i in range(len(PartyManager.party)):
		party[i].show()
		party[i].portrait.texture = party[i].portrait.texture.duplicate()
		party[i].portrait.texture.atlas = PartyManager.party[i].sprite
		party[i].health_bar.update_health(PartyManager.party[i].base_health, PartyManager.party[i].base_health)
		var j = PartyManager.party[i].character_class
		var t = PartyManager.party[i].elemental_type
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

func pick_actor(posit : int) -> void:
	actor = posit
	actor_selected.emit(posit)

func focus_initial() -> void:
	if PartyManager.party[actor].action == UnitData.ActionMode.NONE:
		party[actor].grab_focus()
		return
	
	for member in range(len(PartyManager.party)):
		if (PartyManager.party[member].condition == UnitData.State.NORMAL and 
		PartyManager.party[member].action == UnitData.ActionMode.NONE):
			party[member].grab_focus()
			return
	
	# change this to make start button grab the focus
	party_ready.emit()
