@tool
extends Effect
class_name StatModify

# manipulate a stat of the target

var status_node = preload("res://status_cond.tscn")
@export var effect_name : String = ""

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
	var f = status_node.instantiate() as StatusCondition
	f.name = effect_name
	
	var output = formula.calculate(source.data, recipient.data)
	f.setup(output, recipient, effect_name)
	f.add_to_group("buffs" if is_buff else "debuffs")
	
	if !is_permanent:
		f.set_duration(duration)
	
	if hit_based:
		f.set_hits(hits)
	
	effect_finished.emit()





const remove_toggle : Array[StringName] = [&"duration"]
const hit_toggle : Array[StringName] = [&"hits"]
func _validate_property(property: Dictionary) -> void:
	var hide = false
	match property.name:
		"duration":
			hide = is_permanent
		"hits":
			hide = !hit_based
		"target_mode", "target_group":
			hide = inherit_target
	
	if hide:
		property.usage &= ~PROPERTY_USAGE_DEFAULT
	else:
		property.usage |= PROPERTY_USAGE_DEFAULT
