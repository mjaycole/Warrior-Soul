# The resource file for enemies

extends Resource
class_name EnemyData

@export var id: String
@export var enemy_name: String
@export var max_health: float = 100
@export var prefab: PackedScene

# Movement variables
@export var speed: float = 50

# Audio
@export var death_sound: AudioStream