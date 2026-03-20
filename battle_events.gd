extends RefCounted
class_name BattleEvents

class Win extends GameState:
	var handler : Stage
	
	func _init() -> void:
		state_name = "win"
	
	func start() -> String:
		handler.state_machine.refresh()
		return ""

class GameOver extends GameState:
	var handler : Stage
	
	func _init() -> void:
		state_name = "lose"
	
	func start() -> String:
		handler.state_machine.refresh()
		return ""

class TurnEnd extends GameState:
	var handler : Stage
	
	func _init() -> void:
		state_name = "end"
	
	func begin() -> String:
		print("turn ended")
		RenderingServer.global_shader_parameter_set("screen_dim_amount", 1.0)
		handler.acted.clear()
		return ""
	
	func update(_delta: float) -> String:
		if handler.enemies.is_wave_clear():
			print("Wave Clear!")
			if !handler.load_next_wave():
				print("Stage Clear!")
				return "win"
		return "pop"

class TurnStart extends GameState:
	var handler : Stage
	
	func _init() -> void:
		state_name = "start"
	
	func update(_delta: float) -> String:
		handler.start_turn()
		handler.state_machine.change("end")
		handler.state_machine.change("combat")
		return "plan"

class PlanState extends GameState:
	var handler : Stage
	
	func _init() -> void:
		state_name = "plan"
	
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
	
	func _init() -> void:
		state_name = "combat"
	
	func start() -> String:
		RenderingServer.global_shader_parameter_set("screen_dim_amount", 0.3)
		print("Battle Starting!")
		return ""
	
	func update(_delta: float) -> String:
		handler.update_turn_order()
		if !handler.turn_queue.is_empty() and handler.enemies._vacancies < 5:
			return "act"
		return "pop"

class ActingState extends GameState:
	var handler : Stage
	var actor : Entity
	var action_finished := true
	
	func _init() -> void:
		state_name = "action"
	
	func begin() -> String:
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
		await handler.clear_the_dead()
		cont.clear_queue()
		action_finished = true
	
	func update(_delta: float) -> String:
		if action_finished:
			if handler.heroes.wiped():
				return "lose"
			return "pop"
		return ""

class CutsceneState extends GameState:
	pass
