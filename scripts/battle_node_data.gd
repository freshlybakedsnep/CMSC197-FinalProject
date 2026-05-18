extends Resource
class_name BattleNodeData

@export var label: String = ""
@export var battle_id: StringName
@export var battle_scene: PackedScene
@export var stage_info : StageInfo
@export var min_level: int = 1
@export var reward_gold: int = 0
@export var reward_exp: int = 0
@export var unlock_heroes: PackedStringArray = []
@export var world_pos: Vector2 = Vector2.ZERO
