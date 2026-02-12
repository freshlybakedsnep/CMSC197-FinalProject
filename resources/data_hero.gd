extends UnitData
class_name HeroData

const MAX_SKILLS_SLOT = 2

@export var base_gain := 5
var gain

@export var character_class : CharacterClass
enum CharacterClass {
	DUELIST,
	JUGGERNAUT,
	HEALER,
	TACTICIAN,
	VANDAL
}

func get_current_ability():
	match action:
		UnitData.ActionMode.BASIC_ATTACK:
			return basic_atk[0]
		UnitData.ActionMode.GUARD_ATTACK:
			return skill_use[0]
		UnitData.ActionMode.SKILL_SLOT1:
			return skill_use[1]
		UnitData.ActionMode.SKILL_SLOT2:
			return skill_use[2]
		UnitData.ActionMode.SKILL_EXTRA:
			return skill_ult[0]
		_:
			return null
