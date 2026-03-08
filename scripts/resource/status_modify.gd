extends StatusCondition
class_name StatusMod

var value := 0
var stat : StringName

func apply() -> void:
	host.data.modify_stat(stat, value)
	host.statuses.add_child(self)
	var text = stat + (" UP" if is_buff else " DOWN")
	var c = Color(1.0, 0.753, 0.45, 1.0) if is_buff else Color(0.655, 0.732, 0.78, 1.0)
	await spawn_label(text, c)

func revert() -> void:
	host.data.modify_stat(stat, -value) 
