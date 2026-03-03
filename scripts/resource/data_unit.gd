@abstract
extends Resource
class_name UnitData

signal health_changed(current : int, maximum : int)

# fixed values
const TypeChart = {
	ElementalType.FIRE : 	{ElementalType.WATER: 	2.0, 	ElementalType.WOOD: 	0.5},
	ElementalType.WATER : 	{ElementalType.WOOD: 	2.0, 	ElementalType.FIRE: 	0.5},
	ElementalType.WOOD : 	{ElementalType.FIRE: 	2.0, 	ElementalType.WATER: 	0.5},
	ElementalType.LIGHT : 	{ElementalType.DARK: 	2.0},
	ElementalType.DARK : 	{ElementalType.LIGHT: 	2.0}
}

@export_category("Character Information")
@export var entity_name := "Entity"
@export var character_model := PackedScene
@export var sprite : Texture

@export_group("Character Kit")
@export var elemental_type : ElementalType
enum ElementalType { FIRE, WATER, WOOD, LIGHT, DARK}
@export var basic_atk : Array[Ability]
@export var skills : Array[Ability]
@export var ultimate : Array[Ability]

@export_group("Base Stats")
@export var base_health := 10
@export var base_attack := 4
@export var base_defense := 2
@export var base_speed := 5

# run time : will be used at the start of a stage
@export_group("")
var health : int :
	set(value):
		health = clamp(value, 0, health_max)
		health_changed.emit(health, health_max)
var health_max : int
var attack : int
var defense : int
var speed : int
var element : ElementalType

var state : State :
	set(value):
		if health <= 0:
			state = State.DEAD
		else:
			state = value
enum State {DEAD, DOWN, NORMAL}

# other modifiers
var action : ActionMode
enum ActionMode{
	NONE,
	BASIC_ATTACK,
	GUARD_ATTACK,
	SKILL_SLOT1,
	SKILL_SLOT2,
	SKILL_EXTRA
}

@abstract func get_ability(act : ActionMode = ActionMode.NONE) -> Ability

func get_effectiveness(element : ElementalType) -> float:
	return TypeChart[elemental_type].get(element, 1.0)

@abstract func reset_to_default() -> void
