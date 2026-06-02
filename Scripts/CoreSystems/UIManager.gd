#Handles the direction of the UI based on the game state

extends Node
class_name UIManager

var current_menu

#Godot functions
func _ready():
	Core.register_ui_manager(self)

#UI Changing
func show_main_menu():
	if current_menu:
		current_menu.queue_free()
		
	current_menu = preload("res://Nodes/Menus/main_menu.tscn").instantiate()
	add_child(current_menu)
	
	current_menu.start_new_game.connect(start_new_game)
	current_menu.load_game.connect(load_game)
	
	AudioManagerNode.play_music(preload("res://Audio/Music/EldenRing_Main.mp3"))


func show_sandbox_ui():
	if current_menu:
		current_menu.queue_free()
	
	current_menu = preload("res://Nodes/UI/in_game_hud.tscn").instantiate()
	add_child(current_menu)
	
	AudioManagerNode.play_music(preload("res://Audio/Music/EldenRing_Limgrave.mp3"))

#Signal Handling
func start_new_game():
	Core.start_game()

func load_game(slot: int):
	return;
