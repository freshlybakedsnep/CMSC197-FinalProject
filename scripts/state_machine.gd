extends Node
class_name GameStateMachine

var handler

var stack : Array[GameState]
var pending : Array = []
var state_registry : Dictionary = {}
var memory : Dictionary

func register_state(_name: String, state_class: GDScript) -> void:
	state_registry[_name] = state_class

func change(state_name: String) -> void:
	pending.append(state_name)

func back() -> void: pending.append(&"pop")
func clear() -> void: pending.append(&"clear")
func refresh() -> void: pending.append(&"refresh")
func current() -> GameState: return stack.back() if stack else null

func _process(delta: float) -> void:
	if stack.is_empty(): return
	
	var state : GameState = stack.back()
	var repeat := false
	
	# START
	if not state.started:
		state.started = true
		repeat = state.start() == &"repeat"
	
	# BEGIN
	if not repeat and not state.processed:
		state.processed = true
		repeat = state.begin() == &"repeat"
	
	# INPUT
	if not repeat:
		var event = _get_current_input()
		repeat = state.take_input(event) == &"repeat"
	
	# UPDATED
	if not repeat: repeat = state.update(delta) == &"repeat"
	
	# DRAW
	if not repeat: _draw_stack()
	
	# END
	if not pending.is_empty() and state.processed:
		state.processed = false
		state.end()
	
	_process_pending()

func _pop(s: GameState):
	s.end()
	s.finish()

func _process_pending() -> void:
	for transition: Variant in pending:
		match transition:
			&"pop":
				if stack.size() > 0:
					_pop(stack.pop_back())
			&"clear":
				while stack.size() > 0:
					_pop(stack.pop_back())
			&"refresh":
				while stack.size() > 1:
					_pop(stack.pop_front())
			_:
				var new_state: GameState = state_registry[transition].new()
				if &"handler" in new_state:
					new_state.handler = self.handler
				new_state.state_name = transition
				stack.append(new_state)
	#print(stack.map(func(x): return x.state_name))
	pending.clear()

func _draw_stack() -> void:
	var start_idx := stack.size() - 1
	while start_idx > 0 and stack[start_idx].transparent:
		start_idx -= 1
	
	for i: int in range(start_idx, stack.size()):
		stack[i].draw(get_tree().root)

var last_input : InputEvent
func _input(event: InputEvent) -> void:
	last_input = event

func _get_current_input() -> InputEvent:
	var x := last_input
	last_input = null
	return x
