@tool
extends Resource
class_name Action

enum TargetGroup {SELF, ALLY_ONLY, PARTY, ENEMY}
enum TargetMode {SINGLE, MULTIPLE, AOE, RANDOM }
enum TargetState {ALIVE, DEAD, ANY}

@export var action_name : String
@export var action_icon : Texture

@export var action_description : String = ""

# basically whether this action should be prioritized in the action order
# in prep for abilities that need to take precedence or not
@export var priority : int = 0
@export var level : int = 1: 
	set(value):
		level = clamp(value, 1, 5)
		notify_property_list_changed()
@export var target_group : TargetGroup:
	set(value):
		target_group = value
		notify_property_list_changed()

@export var target_mode : TargetMode:
	set(value):
		target_mode = value
		notify_property_list_changed()

@export var target_count : int = 1 : 
	set(value):
		target_count = clampi(value, 1, 5)
@export var cooldown : int
@export var cost : int

@export var target_state : TargetState = TargetState.ALIVE

@export var effect_groups : Array[EffectGroup]

func _validate_property(property: Dictionary) -> void:
	if property.name in ["target_mode", "target_count", "target_state"]:
		var hide := false
		match property.name:
			"target_mode", "target_state":
				hide = target_group == TargetGroup.SELF
			"target_count":
				hide = (target_mode == TargetMode.AOE or
					target_mode == TargetMode.SINGLE or 
					target_group == TargetGroup.SELF)
		if hide:
			property.usage &= ~PROPERTY_USAGE_EDITOR
		else:
			property.usage |= PROPERTY_USAGE_EDITOR

func summarize_effects() -> String:
	var values = []
	for group in effect_groups:
		#var target : TargetGroup
		#if group.inherit_target: target = target_group
		#else: target = group.target_group

		for effect: Effect in group.effects:
			var val = ""
			match effect:
				var hp when hp is HealthEffect:
					val = val_string(hp.formula)
				
				var stat when stat is StatusEffect:
					var s = stat as StatusEffect
					if s.behavior == StatusEffect.Behavior.NONE:
						val = val_string(stat.formula) + " "
						
					val += s.status_key
			values.append(val)
	return action_description.format(values)

func val_string(value: ValueFormula) -> String:
	match value:
		var s when s is ValueScaling:
			return "{val}% {desc}{stat}".format({
				"val": ((s as ValueScaling).multiplier + 
						((s as ValueScaling).mult_per_level * level)) * 100,
				"desc": "" if (s as ValueScaling).from_target else "of own ",
				"stat": (s as ValueScaling).stat_key,
			})
		
		var f when f is ValueFlat:
			var base = (f as ValueFlat).amount
			var mult = (f as ValueFlat).amount_gain_per_level * level
			return str(base + mult)
		
		var c when c is ValueComposite:
			var m := []
			for val in (c as ValueComposite).values:
				m.append(val_string(val))
			return " + ".join(m)
	return ""
