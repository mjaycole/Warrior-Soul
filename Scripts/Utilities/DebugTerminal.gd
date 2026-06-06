# Handles the terminal for me to use to debug

extends Control

signal terminal_enter_pressed(entered_input)

@onready var line_edit: LineEdit = $Entry/LineEdit
@onready var text_window: RichTextLabel = $Output/Label

var opened
var input: String


func _ready():
	line_edit.text_submitted.connect(_on_text_submitted)
	Core.terminal_response.connect(_on_terminal_response)


func command_toggle(_on: bool):
	opened = _on
	
	if opened:
		line_edit.clear()
		line_edit.call_deferred("grab_focus")

func _on_text_submitted(text: String):
	input = text
	text_window.append_text("\n" + text)

	terminal_enter_pressed.emit(input)

	line_edit.clear()

func _on_terminal_response(response: String):
	text_window.append_text("\n[color=yellow]" + response + "[/color]")