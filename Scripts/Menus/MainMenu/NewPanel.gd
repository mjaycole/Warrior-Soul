#The main manager of the "New Game" panel

extends Node

signal start_new_game_clicked
signal back_button_clicked

@onready var start_button = $VBoxContainer/StartGame
@onready var back_button = $VBoxContainer/Back

func _ready():
	start_button.pressed.connect(start_new_game_clicked.emit)
	back_button.pressed.connect(back_button_clicked.emit)
