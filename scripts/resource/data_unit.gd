@abstract
extends Resource
class_name UnitData

# fixed values
@export var entity_name := "Entity"
@export var character_model := PackedScene
@export var elemental_type : ElementalType
enum ElementalType {
	FIRE,
	WATER,
	WOOD,
	LIGHT,
	DARK
}
const TypeChart = {
	ElementalType.FIRE : 	{ElementalType.WATER: 	2.0, 	ElementalType.WOOD: 	0.5},
	ElementalType.WATER : 	{ElementalType.WOOD: 	2.0, 	ElementalType.FIRE: 	0.5},
	ElementalType.WOOD : 	{ElementalType.FIRE: 	2.0, 	ElementalType.WATER: 	0.5},
	ElementalType.LIGHT : 	{ElementalType.DARK: 	2.0},
	ElementalType.DARK : 	{ElementalType.LIGHT: 	2.0}
}

@export var base_health := 10
@export var base_attack := 4
@export var base_defense := 2
@export var base_speed := 5

@export var sprite : Texture

@export var basic_atk : Array[Ability]
@export var skills : Array[Ability]
@export var ultimate : Array[Ability]

# will be loaded at the start of a stage
var health : int
var health_max : int
var attack : int
var defense : int
var speed : int

var state : State
enum State {
	NORMAL,	# alive, can act, can be damaged
	DOWN,	# not alive, cannot act, cannot be damaged 
	DULL 	# alive, but cannot act, can be damaged
}
enum ActionMode{
	NONE,
	BASIC_ATTACK,
	GUARD_ATTACK,
	SKILL_SLOT1,
	SKILL_SLOT2,
	SKILL_EXTRA
}

@abstract func get_ability(_actor : Entity = null) -> Ability

func get_effectiveness(element : ElementalType) -> float:
	return TypeChart[elemental_type].get(element, 1.0)

func reset_to_default() -> void:
	health_max = base_health
	health = health_max
	attack = base_attack
	defense = base_defense
	speed = base_speed

func update_data(new : Entity) -> void:
	health_max = new.health_max
	health = new.health
	attack = new.attack
	defense = new.defense
	speed = new.speed
