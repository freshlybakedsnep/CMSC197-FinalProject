extends Area2D
class_name Entity

signal entity_action_over
signal entity_eliminated
signal dead

var data : EntityData

@onready var sprite : AnimatedSprite2D = $Sprite
@onready var hp_bar : HPBar = $HPBar
@onready var target_component: Button = $TargetComponent

func _ready() -> void:
	input_event.connect(_on_input_event)
	mouse_entered.connect(func():
		if target_component.visible:
			target_component.grab_focus())
	mouse_exited.connect(func():
		if target_component.visible:
			target_component.release_focus())
	
	data.state_changed.connect(_on_state_changed)
	
	var stats : StatsComponent = data.get_comp(EntityComponent.Type.STATS)
	if stats:
		hp_bar.initialize(stats.get_stat("CURR_HP"), stats.get_stat("HP"))
		stats.health_changed.connect(hp_bar.update)
	var res_comp : ResourceComponent = data.get_comp(EntityComponent.Type.RESOURCE)
	$HPBar/Resource.visible = (res_comp != null)
	if res_comp:
		pass
		# code to connect with the corresponding resource bar
		#res_comp.resource_changed.connect(func(x,y): print(x,y))
	
	if data.state == EntityData.State.DEAD:
		stats.modify_stat("CURR_HP", -1)
	
	position_health_bar()

func position_health_bar():
	var frame_tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var sprite_height = frame_tex.get_size().y * sprite.scale.y
	
	var offset = 0
	if data.faction == EntityData.Faction.ENEMY:
		offset = -10
		$HPBar/Name.text = name
		$HPBar/Icon.show()
		
		var elem = data.get_comp(EntityComponent.Type.ELEMENT)
		$HPBar/Icon.texture = load("res://assets/jobs/El%s.png" % str(elem.my_elem + 1))
	else:
		$HPBar/Icon.hide()
		$HPBar/Name.hide()
	hp_bar.position.y = -(sprite_height / 2) + offset
	target_component.position.y = hp_bar.position.y

func setup(res: EntityData) -> void:
	data = res
	name = res.entity_name
	data.host = self

func _on_state_changed(new_state: EntityData.State) -> void:
	match new_state:
		EntityData.State.DEAD:
			entity_eliminated.emit()
			await die()
		EntityData.State.NORMAL:
			sprite.self_modulate.a = 1.0
			# respawn animation if dead

func new_turn() -> void:
	var act_sys : ActionComponent = data.get_comp(ElementComponent.Type.ACTION)
	if act_sys: act_sys.tick_cooldowns()
	
	var res_sys : ResourceComponent = data.get_comp(EntityComponent.Type.RESOURCE)
	if res_sys: res_sys.on_turn_start()
	
	var status : StatusComponent = data.get_comp(EntityComponent.Type.STATUS)
	if status: status.tick_turns()
	
	var cont = data.get_comp(EntityComponent.Type.CONTROLLER)
	if cont: cont.clear_queue()

func die() -> void:
	# place death animation here
	# temporary
	var t : Tween = create_tween()
	t.tween_property(sprite, "self_modulate:a", 0.0, 0.6)
	await t.finished
	dead.emit()

func highlight_me(enabled : bool) -> void:
	sprite.material.set_shader_parameter("is_bright", enabled)

func outline_me(enabled : bool) -> void:
	sprite.material.set_shader_parameter("active", enabled)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void: 
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			var stats = data.get_comp(EntityComponent.Type.STATS)
			if stats:
				print("%s: %d/%d" % [name, stats.get_stat("CURR_HP"), stats.get_stat("HP")])
			if target_component.visible:
				target_component.pressed.emit()
