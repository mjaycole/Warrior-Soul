# Handles fetching the GameWorldData from the GameWorldLibrary

extends Node
class_name GameWorldFetcher

static var _game_world_array: Array = [GameWorldData]
static var _game_worlds: Dictionary = {}

func _ready():
	var library: GameWorldLibrary = load("res://Resources/Data/game_world_library.tres")
	
	for world in library.all_worlds:
		_game_worlds[world.world_name] = world
		_game_world_array.append(world)

func get_all_worlds() -> Array:
	return _game_world_array

static func get_world(name: String) -> GameWorldData:
	return _game_worlds.get(name, null)
