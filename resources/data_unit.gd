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

# dynamic values
var health
var health_max
var attack
var defense
var speed

@export var basic_atk : Array[Ability]
@export var skill_use : Array[Ability]
@export var skill_ult : Array[Ability]

var condition : State = State.NORMAL
enum State {
	NORMAL,
	DOWN,
	DEAD,
	INACTIVE
}

var targetable := true

var action : ActionMode
enum ActionMode{
	NONE,
	BASIC_ATTACK,
	GUARD_ATTACK,
	SKILL_SLOT1,
	SKILL_SLOT2,
	SKILL_EXTRA
}

var target
var target_range : Array

func get_current_ability():
	pass

func initialize() -> void:
	health_max = base_health
	health = health_max
	attack = base_attack
	defense = base_defense
	speed = base_speed
