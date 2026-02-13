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

@export var base_health := 10
@export var base_attack := 4
@export var base_defense := 2
@export var base_speed := 5

@export var sprite : Texture

@export var basic_atk : Array[Ability]
@export var skills : Array[Ability]
@export var ultimate : Array[Ability]

enum State {
	NORMAL,
	DOWN,
	DEAD,
	INACTIVE
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
