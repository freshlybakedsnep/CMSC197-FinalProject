@tool
extends Effect
class_name StatModify

# manipulate a stat of the target

var status_node = preload("res://scenes/status_cond.tscn")
@export var effect_name : String = ""

@export var stat : ModifiableStat
enum ModifiableStat {
	HEALTH_MAX,
	ATTACK,
	DEFENSE,
	SPEED
}

@export var is_buff := true
@export var is_removable := true 
@export var is_permanent := false:
	set(value):
		is_permanent = value
		self.notify_property_list_changed()
@export var duration := 1 :
	set(value): duration = max(1, value)

@export var hit_based := false :
	set(value):
		hit_based = value
		self.notify_property_list_changed()
@export var hits := 1 :
	set(value): hits = max(1, value)

func trigger(source : Entity, recipient : Entity) -> void:
	if !is_instance_valid(recipient):
		effect_finished.emit()
		return
	
	var f = status_node.instantiate() as StatusCondition
	var info := {
		"host": recipient,
		"name": effect_name,
		"stat": ModifiableStat.find_key(stat),
		"value": formula.calculate(source.data, recipient.data),
		"is_buff": is_buff,
		"is_removable": is_removable,
		"is_permanent": is_permanent,
		"duration": duration,
		"hit-based": hit_based,
		"hits": hits
	}
	f.setup(info)
	f.add_to_group("buffs" if is_buff else "debuffs")
	
	recipient.highlight_me(true)
	await recipient.apply_status(f, ModifiableStat.find_key(stat))
	effect_finished.emit()

func _validate_property(property: Dictionary) -> void:
	var hide = false
	match property.name:
		"duration":
			hide = is_permanent
		"hits":
			hide = !hit_based
	if hide:
		property.usage &= ~PROPERTY_USAGE_DEFAULT
	else:
		property.usage |= PROPERTY_USAGE_DEFAULT
