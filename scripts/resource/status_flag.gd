extends StatusCondition
class_name StatusFlag

var type : StatFlag.Flag

func apply() -> void:
	var key = StatFlag.Flag.find_key(type)
	if host.data.flags.has(key):
		host.data.flags[key] += 1
	else:
		host.data.flags[key] = 1
	host.statuses.add_child(self)
	await spawn_label(key + "!")

func revert() -> void:
	var key = StatFlag.Flag.find_key(type)
	if host.data.flags.has(key):
		host.data.flags[key] -= 1
