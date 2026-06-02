#The main manager of the main menu

extends Node

signal start_new_game
signal load_game(save_slot)

@onready var home_panel = $HomePanel
@onready var new_panel = $NewPanel
@onready var load_panel = $LoadPanel
@onready var settings_panel = $SettingsPanel


func _ready():
	event_listeners()
	show_panel(home_panel)

#Add appropriate listeners to the signals
func event_listeners():
	home_panel.new_clicked.connect(func(): show_panel(new_panel))
	home_panel.load_clicked.connect(func(): show_panel(load_panel))
	home_panel.settings_clicked.connect(func(): show_panel(settings_panel))
	home_panel.quit_clicked.connect(func(): get_tree().quit())
	new_panel.start_new_game_clicked.connect(func(): start_new_game.emit())
	new_panel.back_button_clicked.connect(func(): show_panel(home_panel))

func show_panel(panel: Control):
	#Hide all the panels
	home_panel.hide()
	new_panel.hide()
	load_panel.hide()
	settings_panel.hide()	
	
	#Show the one we want
	panel.show()	
