# Handles loading in the appropriate GameWorld

extends Node
class_name  GameWorldManager

var current_world: GameWorld

func _ready():
	Core.register_game_world_manager(self)
	Core.terminal_object_spawned.connect(_handle_terminal_object_spawned)

func load_sandbox():
	if current_world:
		current_world.command_unload_world()
		await current_world.unload_completed
		current_world.queue_free()
		
	current_world = preload("res://Nodes/GameWorlds/sandbox.tscn").instantiate()
	add_child(current_world)

	current_world.world_ready.connect(_handle_world_ready)
	current_world.player_spawned.connect(_handle_player_spawned)
	current_world.command_load_world()

func _handle_world_ready():
	return

func _handle_player_spawned(player: Node):
	Core.current_player_object = player

func _handle_terminal_object_spawned(object: PackedScene):
	current_world.spawn_object(object)