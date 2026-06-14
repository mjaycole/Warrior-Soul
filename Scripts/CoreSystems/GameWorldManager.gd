# Handles loading in the appropriate GameWorld

extends Node
class_name  GameWorldManager

var current_world: GameWorld
var last_world: GameWorld

func _ready():
	Core.register_game_world_manager(self)
	Core.terminal_object_spawned.connect(_handle_terminal_object_spawned)

func load_new_world(new_world: GameWorldData):
	print("Received command")
	if current_world:
		var unload_signal = current_world.unload_completed
		last_world = current_world
		current_world.command_unload_world()

		# await unload_signal

		print("Cleared existing world")
		current_world.queue_free()

	print("Pulling world scene")
	current_world = new_world.game_world.instantiate()
	add_child(current_world)

	current_world.world_ready.connect(_handle_world_ready)
	current_world.player_spawned.connect(_handle_player_spawned)
	current_world.new_game_world_requested.connect(_handle_transition_request)

	current_world.command_load_world(last_world.world_data if last_world else null)

func load_sandbox():
	if current_world:
		current_world.command_unload_world()
		await current_world.unload_completed
		current_world.queue_free()
		
	current_world = load("res://Nodes/GameWorlds/sandbox.tscn").instantiate()
	add_child(current_world)

	current_world.world_data = GameWorldDataFetcher.get_world("sandbox")
	current_world.world_ready.connect(_handle_world_ready)
	current_world.player_spawned.connect(_handle_player_spawned)
	current_world.new_game_world_requested.connect(_handle_transition_request)

	current_world.command_load_world()

func _handle_world_ready():
	return

func _handle_player_spawned(player: Node):
	Core.current_player_object = player

func _handle_terminal_object_spawned(object: PackedScene, type: String):
	current_world.spawn_object(object, type)

# Handle the request to move to another game world
func _handle_transition_request(new_world: String):
	var new_world_data = GameWorldDataFetcher.get_world(new_world)

	if new_world_data:
		print("Player requested to transition to: ", new_world_data.world_name)

		load_new_world(new_world_data)
	else:
		print("new_world is null")
