extends Control
class_name BattleMenu
signal plan_done

@onready var party_menu: HBoxContainer = $PartyMenu
@onready var start_battle: Button = $MarginContainer/StartBattle

var hero_nodes : Array[Entity]
var current_hero_node : Entity

var enemy_formation : Dictionary
var stack : Array
var actor : int

const ACTION_MENU = preload("res://scenes/ui/menu_action.tscn")
const SKILLS_MENU = preload("res://scenes/ui/menu_skill.tscn")
const TARGET_MENU = preload("res://scenes/ui/menu_target.tscn")

func _ready() -> void:
	stack.append(party_menu)

func connect_formations(enemies : Dictionary, heroes : Array[Entity]) -> void:
	enemy_formation = enemies
	hero_nodes = heroes
	party_menu.setup(hero_nodes)

func turn_start() -> void:
	start_battle.disabled = true
	start_battle.focus_mode = Control.FOCUS_NONE
	party_menu.enable()
	actor = 0
	party_menu.focus_initial()

func open(menu : Node) -> void:
	if not stack.is_empty():
		stack.back().disable()
	
	if stack.size() > 1:
		start_battle.disabled = true
		start_battle.focus_mode = Control.FOCUS_NONE
	
	stack.append(menu)
	if menu.has_method("focus_initial"):
		menu.call_deferred("focus_initial")

func close() -> void:
	var top = stack.pop_back()
	top.queue_free()
	if not stack.is_empty():
		var prev = stack.back()
		prev.enable()
		if prev.has_method("focus_initial"):
			prev.call_deferred("focus_initial")

func close_to_root():
	while stack.size() > 1:
		close()

func draw_menu(menu : Control, reference : Control, menu_offset : Vector2) -> void: 
	var target_pos = reference.global_position
	var spawn_pos = Vector2(target_pos.x, target_pos.y - menu.size.y) + menu_offset
	
	menu.global_position = spawn_pos

func _spawn_menu(
	menu_scene: PackedScene, 
	member_pos: Entity, 
	next_op : Callable, 
	spawn_anc = null, 
	offset = Vector2.ZERO
	) -> Control:
	var menu = menu_scene.instantiate()
	if menu.has_method("link_member"):
		menu.link_member(member_pos)
	
	add_child(menu)
	menu.connect("cancel_op", close)
	menu.connect("finish_op", next_op)
	
	if spawn_anc:
		draw_menu(menu, spawn_anc, offset)
	
	open(menu)
	return menu

func _open_action_menu(index: int) -> void:
	current_hero_node = hero_nodes[index]
	
	var menu = _spawn_menu(ACTION_MENU, current_hero_node, _open_target_menu, 
			party_menu.get_child(index), Vector2(0, -10))
	menu.connect("open_skill_menu", _open_skill_menu)

func _open_skill_menu() -> void:
	_spawn_menu(SKILLS_MENU, current_hero_node, _open_target_menu,
	stack.back(), Vector2(-10, 40))

func _open_target_menu() -> void:
	var ability = current_hero_node.get_ability()
	current_hero_node.set_target_range()
	if not ability: return
	
	if ability.mode == Ability.TargetMode.SINGLE:
		var menu = _spawn_menu(TARGET_MENU, current_hero_node, close_to_root)
		menu.setup(current_hero_node.target_range)
	else:
		current_hero_node.current_target.assign(current_hero_node.target_range)
		close_to_root()

func _on_party_ready() -> void:
	print("Ready for Battle!")
	start_battle.disabled = false
	
	start_battle.focus_mode = Control.FOCUS_ALL
	start_battle.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	start_battle.grab_focus()

func _on_start_battle_pressed() -> void:
	print("Battle Starting!")
	actor = 0
	party_menu.actor = 0
	party_menu.disable()
	plan_done.emit()
	
	start_battle.focus_mode = Control.FOCUS_NONE
	start_battle.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
