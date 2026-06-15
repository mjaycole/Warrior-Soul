# Handles loading in the appropriate GameWorld

extends Node
class_name  GameWorldManager

var current_world_data: GameWorldData
var current_world: GameWorld
var last_world: GameWorld


func _ready():
	Core.register_game_world_manager(self)
	Core.terminal_object_spawned.connect(_handle_terminal_object_spawned)

# Load a new world and store the previous one
func load_new_world(new_world: GameWorldData):
	# If current world exists, unload it
	if current_world:
		await unload_current_world()

	current_world_data = new_world
	current_world = new_world.game_world.instantiate()
	add_child(current_world)

	setup_current_world()

func load_sandbox():
	if current_world:
		await  unload_current_world()
		
	current_world = load("res://Nodes/GameWorlds/sandbox.tscn").instantiate()
	add_child(current_world)

	current_world_data = GameWorldDataFetcher.get_world("sandbox")
	current_world.world_data = current_world_data

	setup_current_world()


#region Current world setup and unloading
func setup_current_world():
	current_world.world_ready.connect(_handle_world_ready)
	current_world.player_spawned.connect(_handle_player_spawned)
	current_world.new_game_world_requested.connect(_handle_transition_request)

	current_world.command_load_world()

	EventBus.world_loaded.emit(current_world_data.world_name)

func unload_current_world():
	# var unload_signal = current_world.unload_completed
	last_world = current_world
	current_world.command_unload_world()

	# await unload_signal

	current_world.queue_free()

	EventBus.world_unloaded.emit()

#endregion

#region Listeners for the current game world
func _handle_world_ready():
	return

# Listens for the player spawn
func _handle_player_spawned(player: Node):
	EventBus.player_spawned.emit(player)

# Handle the request to move to another game world
func _handle_transition_request(new_world: String):
	var new_world_data = GameWorldDataFetcher.get_world(new_world)

	if new_world_data:
		load_new_world(new_world_data)
	else:
		print("new_world is null")

#endregion



func _handle_terminal_object_spawned(object: PackedScene, type: String):
	current_world.spawn_object(object, type)
