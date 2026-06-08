#The core director of the game, handles initializing the game nodes

extends Node

#region Game State
enum GameState { MAIN_MENU, PLAYING, PAUSED }
var state: GameState = GameState.MAIN_MENU

#endregion

#region Managers
var ui_manager: UIManager
var game_world_manager: GameWorldManager

#endregion

#region Resources
@export var player_data: PlayerData
@export var debug_mode: bool = false

#endregion

#region Signals
signal input_availability_changed(available: bool)
signal terminal_object_spawned(object: PackedScene)
signal terminal_response(response: String)
#endregion

#region Variables
var current_player_object
var input_enabled: bool = true

#endregion




#region Register managers
func register_ui_manager(manager: UIManager):
	ui_manager = manager
	ui_manager.terminal_toggled.connect(handle_terminal_toggled)
	ui_manager.terminal_enter_pressed.connect(handle_terminal_input)

func register_game_world_manager(manager: GameWorldManager):
	game_world_manager = manager

func initialize():
	change_game_state(GameState.MAIN_MENU)

#endregion

#region Handle game state change
func change_game_state(new_state: GameState):
	state = new_state
	
	match state:
		GameState.MAIN_MENU: handle_main_menu()
		GameState.PLAYING: handle_playing()
		GameState.PAUSED: return

func handle_main_menu():
	ui_manager.show_main_menu()
	
func handle_playing():
	ui_manager.show_sandbox_ui()
	game_world_manager.load_sandbox()

func handle_paused():
	return;

#endregion

#region Game state change requests
func start_game():
	# initialize the starting player data if player_data is null (for a new game)
	if not player_data:
		player_data = load("res://Resources/Data/starting_data.tres")
		player_data.initialize()
	
	change_game_state(GameState.PLAYING)

#endregion

#region Debug terminal
func handle_terminal_toggled(on: bool):
	input_enabled = !on

	input_availability_changed.emit(input_enabled)

func handle_terminal_input(input: String):	
	var parts = input.split("_")

	if parts.size() < 1:
		terminal_response.emit("No _ added, could not parse")
		return

	var command = parts[0]
	var args: Array
	for part in parts:
		if part != command:
			args.append(part)

	match command:
		"spawn": spawn_object(args)
		_: terminal_response.emit("Unknown command")

func spawn_object(args: Array):
	if args.size() <= 0:
		terminal_response.emit("No arguments given to spawn command")
		return
	
	# TO DO: Add other spawnable object type commands, such as items and enemies
	var enviro_obj = EnviroObjFetcher.get_object(args[0])

	if enviro_obj:
		terminal_object_spawned.emit(enviro_obj.prefab)
		terminal_response.emit("Attempting to spawn object")
		return
	else:
		terminal_response.emit("Failed to find object name")


# List of commands for the debug terminal
# "spawn" - spawns something in the game world
# "equip" - adds item to player inventory and equips it
# "giveitem" - gives an item to player
# 

#endregion