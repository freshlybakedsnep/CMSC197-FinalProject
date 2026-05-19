extends Resource
class_name BattleNodeData

@export var label: String = ""
@export var battle_id: StringName
@export var battle_scene: PackedScene
@export var background: Texture2D
@export var stage_info : StageInfo
@export var min_level: int = 1
@export var reward_gold: int = 0
@export var reward_exp: int = 0
@export var unlock_heroes: PackedStringArray = []
@export var world_pos: Vector2 = Vector2.ZERO
@export var enemy_formation_position: Vector2 = Vector2(350, 280)
@export var hero_formation_position: Vector2 = Vector2(850, 440)
