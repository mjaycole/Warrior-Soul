#Handles the home panel interaction

extends Node

signal new_clicked
signal load_clicked
signal settings_clicked
signal quit_clicked

@onready var new_button = $Menu/VBoxContainer/New
@onready var load_button = $Menu/VBoxContainer/Load
@onready var settings_button = $Menu/VBoxContainer/Settings
@onready var quit_button = $Menu/VBoxContainer/Quit

func _ready():
	new_button.pressed.connect(new_clicked.emit)
	load_button.pressed.connect(load_clicked.emit)
	settings_button.pressed.connect(settings_clicked.emit)
	quit_button.pressed.connect(quit_clicked.emit)
