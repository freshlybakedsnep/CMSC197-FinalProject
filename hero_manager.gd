extends Node2D
class_name HeroManager

@onready var pos1: Marker2D = $pos1
@onready var pos2: Marker2D = $pos2
@onready var pos3: Marker2D = $pos3
@onready var pos4: Marker2D = $pos4
@onready var pos5: Marker2D = $pos5

var formation : Dictionary[int, Entity] = {
	1: null, 2: null, 3: null, 4: null, 5: null
}

var _positions : Dictionary[int, Marker2D]

func _ready() -> void:
	_positions = {
		1: pos1,
		2: pos2,
		3: pos3,
		4: pos4,
		5: pos5
	}

func setup(spawner : Callable) -> void:
	for i in PartyManager.party.size():
		var hero_res = PartyManager.party[i]
		if hero_res == null: continue
		
		var hero_node = spawner.call(hero_res)
		formation[i+1] = hero_node
		_positions[i+1].add_child(hero_node)
