extends Resource
class_name EntityData

signal state_changed(new_state: State)

# Entity Info
@export var entity_name := "Entity"
@export var sprite : Texture
@export var battle_sprite : SpriteFrames
var host : Entity

# Faction
enum Faction { HERO, ENEMY, NEUTRAL }
var faction : Faction = Faction.ENEMY

# State
enum State { NORMAL, DEAD }
var state : State = State.NORMAL : 
	set(value):
		state = value
		state_changed.emit(value)

# Components
var comp_list : Dictionary = {}
@export var components : Array[EntityComponent]

func initialize() -> void:
	var stats : StatsComponent = get_comp(EntityComponent.Type.STATS)
	if stats: stats.initialize()
	
	var act : ActionComponent = get_comp(EntityComponent.Type.ACTION)
	if act: act.cooldowns.clear()
	
	var status : StatusComponent = get_comp(EntityComponent.Type.STATUS)
	if status: status._active_status.clear()

func initialize_entity() -> void:
	comp_list.clear()
	for comp in components:
		if comp:
			var c = comp.duplicate(true)
			c.set_host(self)
			
			comp_list[c.type] = c
			c.initialize()

func get_comp(type: EntityComponent.Type) -> EntityComponent:
	return comp_list.get(type, null)

func set_host(ent: Entity) -> void:
	host = ent

func is_alive() -> bool:
	return state == State.NORMAL
