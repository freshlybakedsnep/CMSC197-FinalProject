extends StatusCondition
class_name StatusCC

var type : CrowdControl.ControlType

func apply() -> void:
	var key = CrowdControl.ControlType.find_key(type)
	print(key)
	if host.data.ailments.has(key):
		host.data.ailments[key] += 1
	else:
		host.data.ailments[key] = 1
	host.statuses.add_child(self)
	await spawn_label(key + "!")

func revert() -> void:
	var key = CrowdControl.ControlType.find_key(type)
	if host.data.ailments.has(key):
		host.data.ailments[key] -= 1
