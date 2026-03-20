@tool
@abstract
extends Resource
class_name EntityComponent

var type : Type
enum Type {
	STATS,
	ELEMENT,
	ACTION,
	RESOURCE,
	CONTROLLER,
	STATUS,
}

var host : EntityData

func set_host(h: EntityData) -> void:
	host = h

func initialize() -> void:
	pass
