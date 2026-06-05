# Handles the terminal for me to use to debug

extends Control

signal terminal_enter_pressed(entered_input)

@onready var line_edit: LineEdit = $Entry/LineEdit
@onready var text_window: Label = $Output/Label

var opened
var input: String


func _ready():
	line_edit.text_submitted.connect(_on_text_submitted)


func command_toggle(_on: bool):
	opened = _on
	
	if opened:
		line_edit.clear()
		line_edit.call_deferred("grab_focus")
		set_process_input(false)
	else:
		set_process_input(true)

func _on_text_submitted(text: String):
	input = text
	text_window.text += "\n" + text

	terminal_enter_pressed.emit(input)

	line_edit.clear()
	line_edit.call_deferred("grab_focus")
