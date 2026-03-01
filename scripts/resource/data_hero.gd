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



func get_ability(_actor : Entity = null):
	match _actor.current_action:
		UnitData.ActionMode.BASIC_ATTACK:
			return basic_atk[0]
		UnitData.ActionMode.GUARD_ATTACK:
			return skills[0]
		UnitData.ActionMode.SKILL_SLOT1:
			return skills[1]
		UnitData.ActionMode.SKILL_SLOT2:
			return skills[2]
		UnitData.ActionMode.SKILL_EXTRA:
			return ultimate[0]
		_:
			return null
