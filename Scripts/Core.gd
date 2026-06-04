#The core director of the game, handles initializing the game nodes

extends Node

#Game State
enum GameState { MAIN_MENU, PLAYING, PAUSED }
var state: GameState = GameState.MAIN_MENU

#Managers
var ui_manager: UIManager
var game_world_manager: GameWorldManager

#Resources
@export var player_data: PlayerData

#Signals


func change_game_state(new_state: GameState):
	state = new_state
	
	match state:
		GameState.MAIN_MENU: handle_main_menu()
		GameState.PLAYING: handle_playing()
		GameState.PAUSED: return

#Register managers
func register_ui_manager(manager: UIManager):
	ui_manager = manager

func register_game_world_manager(manager: GameWorldManager):
	game_world_manager = manager

func initialize():
	change_game_state(GameState.MAIN_MENU)


#Handle game state change
func handle_main_menu():
	ui_manager.show_main_menu()
	
func handle_playing():
	ui_manager.show_sandbox_ui()
	game_world_manager.load_sandbox()

func handle_paused():
	return;


#Game state change requests
func start_game():
	if not player_data:
		player_data = load("res://Resources/Data/starting_data.tres")
		player_data.initialize()
	
	change_game_state(GameState.PLAYING)
