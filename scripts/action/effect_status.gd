extends Effect
class_name StatusEffect

@export var status_key : StringName

@export_group("Duration")
@export var is_buff : bool = true
@export var turns : int = 1		# set to -1 for permanent
@export var hit_based : bool = false
@export var hits : int = 0
@export var trigger : StatusComponent.Trigger = StatusComponent.Trigger.ON_DEFEND

@export_group("Flags")
@export var behavior : Behavior
enum Behavior { 
# basically a flag check for special behaviors associated with it
	NONE,			# simple status condition application
	INCAPACITATE,	# causes entity to skip their turn
	RESTRICT, 		# limits player's choices
	PROTECT,		# affects damage multiplier
	DOT				# off-battle damage application
}
@export var permanent : bool = false
@export var removable : bool = true

# add an id to allow only one instane of the effect, refreshes lifetime instead
@export var id : String = ""

# toggle to strictly allow only one instance of the effect, no refresh
@export var unique : bool = false

func get_effect_data(src: EntityData, tar: EntityData, level: int) -> Dictionary:
	formula.set_level(level)
	return {
		"type": "STATUS",
		"key": status_key,
		"params": {
			"val": formula.calculate(src, tar),
			"turns": turns,
			"hits": hits,
			"hit-based": hit_based,
			"permanent": permanent,
			"removable": removable,
			"trigger_on": trigger,
			"id": id,
			"is_buff": is_buff,
			"behavior": behavior,
			"caster": src,
			"unique": unique
		}
	}
