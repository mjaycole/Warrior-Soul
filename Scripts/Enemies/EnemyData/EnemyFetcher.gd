# Handles communication with the enemy library

extends Node
class_name EnemyFetcher

static var _enemies_array: Array = []
static var _enemies: Dictionary = {}

func _ready():
	var library: Enemy_Data_Library = load("res://Resources/Data/enemy_library.tres")
	
	for enemy in library.enemies:
		_enemies[enemy.id] = enemy
		_enemies_array.append(enemy)

static func get_all_enemies() -> Array:
	return _enemies_array

static func get_enemy(id: String) -> EnemyData:
	return _enemies.get(id, null)

static func get_enemy_by_packed_scene(scene: PackedScene):
	for enemy in _enemies_array:
		if enemy.prefab == scene:
			return enemy
	return null
