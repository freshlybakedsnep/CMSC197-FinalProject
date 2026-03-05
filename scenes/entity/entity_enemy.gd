extends Entity
class_name Enemy

@onready var element_icon : TextureRect = $HPBar/HealthBar/Icon
@onready var charge: ProgressBar = $HPBar/Charge

func setup(res : UnitData) -> void:
	data = (res as EnemyData)
	name = data.entity_name

func position_health_bar():
	var frame_tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var sprite_height = frame_tex.get_size().y * sprite.scale.y
	hp_bar.position.y = -(sprite_height / 2) - 10
	element_icon.texture = load("res://assets/jobs/El%s.png" % str(data.stats["ELEMENT"]+1))
	$HPBar/Name.text = name
	charge.max_value = data.max_charges
	target_component.position.y = hp_bar.position.y

func new_turn() -> void:
	intent = data.get_ability()
	charge.value = data.stats["CHARGE"]
	set_target()

func end_turn() -> void:
	data.stats["CHARGE"] = min(data.stats["CHARGE"] + 1, (data as EnemyData).max_charges)
	for stat in statuses.get_children():
		(stat as StatusCondition).reduce_duration()

func set_target() -> void:
	current_target.clear()
	intent.lock_entities(self)
	var valid_targets = intent.determine_targets(self, intent)
	
	match intent.target_mode:
		Ability.TargetMode.AOE, Ability.TargetMode.RANDOM:
			current_target.assign(valid_targets)
		_: 
			while true:
				var p = valid_targets.pick_random()
				if p == null: break
				if p.targetable:
					current_target.append(p)
					break
				else:
					valid_targets.erase(p)
