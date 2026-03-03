extends Control
class_name BattleMenu

signal plan_done

@onready var party_menu: PartyMenu = $PartyMenu
@onready var action_menu: ActionMenu = $ActionMenu
@onready var target_menu: TargetMenu = $TargetMenu
@onready var back: Button = $Back
@onready var start_battle: Button = $MarginContainer/StartBattle

var selected_hero : Entity
var menu_stack : Array
var current_hero_node : Entity

var enemy_formation : Dictionary

func _ready() -> void:
	party_menu.hero_selected.connect(_open_action_menu)
	action_menu.action_selected.connect(_open_target_menu)
	target_menu.target_selected.connect(_close_to_root)
	action_menu.add_back(back)
	action_menu.hide()
	target_menu.hide()
	
	menu_stack.append(party_menu)

func connect_formations(enemies : Dictionary, heroes : Array[Entity]) -> void:
	enemy_formation = enemies
	party_menu.setup(heroes)

func turn_start() -> void:
	start_battle.disabled = true
	start_battle.focus_mode = Control.FOCUS_NONE
	party_menu.enabled(true)

func _close_menu() -> void:
	var x = menu_stack.pop_back()
	x.enabled(false)
	x.hide()
	if not menu_stack.is_empty():
		var prev = menu_stack.back()
		prev.enabled(true)

func _close_to_root() -> void:
	while menu_stack.size() > 1:
		_close_menu()

func _open_menu(menu : Control) -> void:
	if not menu_stack.is_empty():
		menu_stack.back().enabled(false)
	
	menu_stack.append(menu)
	menu.enabled(true)
	menu.show()
	
func _open_action_menu(hero : Entity) -> void:
	selected_hero = hero
	action_menu.load_menu(hero)
	_open_menu(action_menu)

func _open_target_menu(action : UnitData.ActionMode) -> void:
	var ability : Ability = selected_hero.data.get_ability(action)
	if not ability: return
	
	ability.lock_sides(selected_hero)
	var target_range := ability.match_suitable_targets(selected_hero, ability.target)
	
	if ability.mode == Ability.TargetMode.SINGLE:
		target_menu.setup(selected_hero, target_range, action)
		_open_menu(target_menu)
	else:
		selected_hero.set_intent(action)
		selected_hero.current_target.assign(target_range)
		_close_to_root()

func _on_party_ready() -> void:
	print("Ready for Battle!")
	start_battle.disabled = false
	
	start_battle.focus_mode = Control.FOCUS_ALL
	start_battle.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	start_battle.grab_focus()

func _on_start_battle_pressed() -> void:
	print("Battle Starting!")
	party_menu.enabled(false)
	plan_done.emit()
	
	start_battle.focus_mode = Control.FOCUS_NONE
	start_battle.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
