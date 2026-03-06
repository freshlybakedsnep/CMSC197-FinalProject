@abstract
extends Node2D
class_name EntityFormation

@onready var pos1: Marker2D = $pos1
@onready var pos2: Marker2D = $pos2
@onready var pos3: Marker2D = $pos3
@onready var pos4: Marker2D = $pos4
@onready var pos5: Marker2D = $pos5

@export var entity_scene : PackedScene

var formation : Dictionary[int, Entity] = {1: null, 2: null, 3: null, 4: null, 5: null}
var _positions : Dictionary[int, Marker2D]
var next_move : Callable
var deathrow : Array

func _ready() -> void:
	_positions = {
		1: pos1,
		2: pos2,
		3: pos3,
		4: pos4,
		5: pos5
	}

func spawn_entity(res) -> Entity:
	var h = entity_scene.instantiate()
	h.setup(res)
	return h

func setup(callable : Callable, death_row : Array) -> void:
	next_move = callable
	deathrow = death_row
