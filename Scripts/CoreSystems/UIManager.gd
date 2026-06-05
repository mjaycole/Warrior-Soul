# Handles the direction of the UI based on the game state

extends Node
class_name UIManager

signal terminal_toggled(on)
signal terminal_enter_pressed(entered_input)

@onready var main_ui_parent = $MainUI
@onready var debug_terminal_parent = $DebugTerminal

var current_menu
var terminal_window

#region Godot functions
func _ready():
	Core.register_ui_manager(self)

	add_terminal()

func _input(event: InputEvent):
	if event.is_action_pressed("Terminal"):
		toggle_terminal()

#endregion

#region UI Changing
func show_main_menu():
	if current_menu:
		current_menu.queue_free()
		
	current_menu = preload("res://Nodes/Menus/main_menu.tscn").instantiate()
	main_ui_parent.add_child(current_menu)
	
	current_menu.start_new_game.connect(start_new_game)
	current_menu.load_game.connect(load_game)
	
	AudioManagerNode.play_music(preload("res://Audio/Music/EldenRing_Main.mp3"))

func show_sandbox_ui():
	if current_menu:
		current_menu.queue_free()
	
	current_menu = preload("res://Nodes/UI/in_game_hud.tscn").instantiate()
	main_ui_parent.add_child(current_menu)
	
	add_terminal()

	AudioManagerNode.play_music(preload("res://Audio/Music/EldenRing_Limgrave.mp3"))

#endregion 

#region Terminal
func add_terminal():
	if terminal_window != null:
		terminal_window.queue_free()

	terminal_window = preload("res://Nodes/debug_terminal.tscn").instantiate()
	debug_terminal_parent.add_child(terminal_window)

	terminal_window.terminal_enter_pressed.connect(handle_terminal_enter_pressed)
	terminal_window.hide()

func toggle_terminal():
	terminal_window.visible = not terminal_window.visible
	terminal_window.command_toggle(terminal_window.visible)

	terminal_toggled.emit(terminal_window.visible)

func handle_terminal_enter_pressed(input: String):
	terminal_enter_pressed.emit(input)

	toggle_terminal()

#endregion

#region Signal Handling
func start_new_game():
	Core.start_game()

func load_game(slot: int):
	return;

#endregion