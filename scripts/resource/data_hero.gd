extends UnitData
class_name HeroData

const MAX_SKILLS_SLOT = 2

# hero related attributes
@export var base_gain := 5
@export var character_class : CharacterClass
enum CharacterClass {
	DUELIST,
	JUGGERNAUT,
	HEALER,
	TACTICIAN,
	VANDAL
}

# on runtime
var gain

@export var ability_preset : Dictionary[ActionMode, Ability] = {
	ActionMode.BASIC_ATTACK : null,
	ActionMode.GUARD_ATTACK : null,
	ActionMode.SKILL_SLOT1 : null,
	ActionMode.SKILL_SLOT2 : null,
	ActionMode.SKILL_EXTRA : null
}

func get_ability(act : ActionMode = ActionMode.NONE) -> Ability:
	return ability_preset[act]

func set_ability(act : ActionMode, ability : Ability) -> void:
	ability_preset.set(act, ability)

func reset_to_default() -> void:
	health_max = base_health
	health = health_max
	attack = base_attack
	defense = base_defense
	speed = base_speed
	element = elemental_type
	
	state = State.NORMAL
	
	ability_preset[ActionMode.BASIC_ATTACK] = basic_atk[0]
	ability_preset[ActionMode.GUARD_ATTACK] = skills[0]
	ability_preset[ActionMode.SKILL_SLOT1] = skills[1]
	ability_preset[ActionMode.SKILL_SLOT2] = skills[2]
	ability_preset[ActionMode.SKILL_EXTRA] = ultimate[0]

func tick_abilities() -> void:
	for a in ability_preset:
		var abil = ability_preset[a]
		abil.downtime = max(0, abil.downtime - 1)
