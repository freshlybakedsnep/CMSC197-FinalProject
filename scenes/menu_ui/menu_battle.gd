extends Node
class_name BattleMenu

signal plan_done

@onready var party_menu: PartyMenu = $PartyMenu
@onready var action_menu: ActionMenu = $ActionMenu
@onready var target_menu: TargetMenu = $TargetMenu

@onready var back: Button = $Back
@onready var start_battle: Button = $MarginContainer/StartBattle
@onready var cursor: Cursor = $Cursor
@onready var tooltip: Panel = $Tooltip

var selected_hero : Entity
var menu_stack : Array

var enemy_formation: Vector2
var hero_formation: Vector2

func _ready() -> void:
	SFX.bind_button_sounds(self)
	party_menu.hero_selected.connect(_open_action_menu)
	action_menu.action_selected.connect(_open_target_menu)
	action_menu.action_tooltip.connect(tooltip.update_display)
	action_menu.add_back(back)
	action_menu.hide()
	target_menu.hide()
	menu_stack.append(party_menu)

func connect_formations(enemies: EnemyFormation, heroes: HeroFormation) -> void:
	enemy_formation = enemies.global_position
	hero_formation = heroes.global_position
	party_menu.setup(heroes.formation.values().filter(func(f): return f))

func enabled(toggle : bool) -> void:
	cursor.visible = toggle
	party_menu.enabled(toggle)
	
	start_battle.visible = toggle
	start_battle.disabled = true
	start_battle.focus_mode = Control.FOCUS_NONE
	
	if toggle:
		self.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		self.process_mode = Node.PROCESS_MODE_DISABLED

func _close_menu() -> void:
	var x = menu_stack.pop_back()
	x.enabled(false)
	x.hide()
	if not menu_stack.is_empty():
		var prev = menu_stack.back()
		prev.enabled(true)
	if menu_stack.size() == 1:
		tooltip.hide()

func _close_to_root() -> void:
	while menu_stack.size() > 1:
		_close_menu()

func _open_menu(menu : Control) -> void:
	if not menu_stack.is_empty():
		menu_stack.back().enabled(false)
	
	menu_stack.append(menu)
	menu.show()
	menu.enabled(true)
	start_battle.disabled = true
	start_battle.focus_mode = Control.FOCUS_NONE
	
func _open_action_menu(hero : Entity) -> void:
	selected_hero = hero
	action_menu.load_menu(hero)
	tooltip.show()
	_open_menu(action_menu)

func _open_target_menu(slot : ActionComponent.Slot) -> void:
	var act_sys : ActionComponent = selected_hero.data.get_comp(EntityComponent.Type.ACTION)
	if act_sys:
		var action = act_sys.get_action(slot)
		if not action: return
		
		target_menu.setup(
			{"selected_hero": selected_hero, 
			"action": action,
			"slot": slot}
		)
		_open_menu(target_menu)

func _on_party_ready() -> void:
	print("Ready for Battle!")
	start_battle.disabled = false
	
	start_battle.focus_mode = Control.FOCUS_ALL
	start_battle.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	start_battle.grab_focus()

func _on_start_battle_pressed() -> void:
	party_menu.selected_hero = null
	enabled(false)
	plan_done.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if cursor.visible:
			_set_cursor_mode(false)
	elif event.is_action_pressed("navigation"):
		if not cursor.visible:
			_set_cursor_mode(true)

func _set_cursor_mode(is_keyboard : bool) -> void:
	var f = get_viewport().gui_get_focus_owner()
	if is_keyboard:
		cursor.show()
		if f == null:
			var menu = menu_stack.back()
			menu.focus_initial()
	else:
		cursor.hide()
		if f:
			f.release_focus()
