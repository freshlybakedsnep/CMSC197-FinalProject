extends GDScript
class_name BattleEvents

class Win extends GameState:
	var handler : Stage
	
	func _init() -> void: state_name = &"win"
	
	func start() -> String:
		handler.state_machine.refresh()
		return ""

class GameOver extends GameState:
	var handler : Stage
	
	func _init() -> void: state_name = &"lose"
	
	func start() -> String:
		handler.state_machine.refresh()
		return ""

class TurnEnd extends GameState:
	var handler : Stage
	var pending_cleared : bool = true
	
	func _init() -> void: state_name = &"end"
	
	func start() -> String:
		handler.end_turn()
		return ""
	
	func begin() -> String:
		pending_cleared = false
		_handle_pending()
		
		if pending_cleared:
			if handler.enemies.is_wave_clear():
				print("Wave Clear!")
				if !handler.load_next_wave():
					print("Stage Clear!")
					handler.state_machine.change(&"win")
					return "repeat"
			handler.state_machine.back()
		return ""
	
	func _handle_pending() -> void:
		await handler.clear_the_dead()
		var next_state = handler.get_next_state()
		match next_state:
			"": pending_cleared = true
			_: handler.state_machine.change(next_state)

class TurnStart extends GameState:
	var handler : Stage
	
	func _init() -> void: state_name = &"start"
	
	func begin() -> String:
		_new_turn()
		return ""
	
	func _new_turn() -> void:
		handler.start_turn()
		handler.state_machine.change(&"end")
		handler.state_machine.change(&"combat")
		handler.state_machine.change(&"plan")
		

class PlanState extends GameState:
	var handler : Stage
	
	func _init() -> void: state_name = &"plan"
	
	func begin() -> String:
		handler.command_ui.enabled(true)
		
		if not handler.command_ui.plan_done.is_connected(_plan_done):
			handler.command_ui.plan_done.connect(_plan_done)
		return ""
	
	func _plan_done():
		handler.command_ui.plan_done.disconnect(_plan_done)
		handler.state_machine.back()

class CombatState extends GameState:
	var handler : Stage
	var pending_cleared : bool = true
	
	func _init() -> void: state_name = &"combat"
	
	func start() -> String:
		RenderingServer.global_shader_parameter_set("screen_dim_amount", 0.3)
		print("Battle Starting!")
		return ""
	
	func begin() -> String:
		pending_cleared = false
		_handle_pending()
		return ""
	
	func update(_delta: float) -> String:
		if pending_cleared:
			
			if handler.heroes.wiped():
				handler.state_machine.change(&"lose")
				return "repeat"
			
			handler.update_turn_order()
			if !handler.turn_queue.is_empty() and handler.enemies._vacancies < 5:
				handler.state_machine.change(&"act")
				return "repeat"
			
			handler.state_machine.back()
		return ""
	
	func _handle_pending() -> void:
		await handler.clear_the_dead()
		var next_state = handler.get_next_state()
		match next_state:
			"": pending_cleared = true
			_: handler.state_machine.change(next_state)

class ActingState extends GameState:
	var handler : Stage
	var actor : Entity
	var action_finished := true
	
	func _init() -> void: state_name = &"action"
	
	func start() -> String:
		actor = handler.turn_queue.pop_front()
		if actor and actor.data.state == EntityData.State.NORMAL:
			handler.acted.append(actor)
			actor.highlight_me(true)
			actor.outline_me(true)
			
			var status : StatusComponent = actor.data.get_comp(EntityComponent.Type.STATUS)
			if status and !status.is_incapacitated():
				var controller = actor.data.get_comp(EntityComponent.Type.CONTROLLER)
				var decision : Dictionary = controller.get_next_action()
				
				if not decision.is_empty():
					action_finished = false
					actor.entity_action_over.connect(_post_action.bind(controller), CONNECT_ONE_SHOT)
					ActionParser.execute(actor, decision["action"], decision["targets"])
			else:
				print(actor.name + " is STUNNED! Skipping turn.")
		return ""
	
	func _post_action(cont: EntityComponent) -> void:
		await handler.get_tree().create_timer(0.5).timeout
		cont.clear_queue()
		action_finished = true
	
	func update(_delta: float) -> String:
		if action_finished: handler.state_machine.back()
		return ""

class CutsceneState extends GameState:
	pass

class AsyncEffectState extends GameState:
	var handler : Stage
	var event : Dictionary
	
	func _init() -> void: state_name = &"async"
	func begin() -> String:
		event = handler.process_pending()
		event.get(&"host").host.entity_effect_triggered.connect(_effect_finish)
		event.get(&"call").call()
		return ""
	
	func _effect_finish() -> void:
		await handler.get_tree().create_timer(0.5).timeout
		handler.state_machine.back()

class FollowUpState extends GameState:
	func _init() -> void: state_name = &"follow up"
