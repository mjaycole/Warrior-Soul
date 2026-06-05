#The bootstrap startup

extends Node


func _ready():
	if get_meta("SkipMenu"):
		Core.start_game()
	else:
		Core.initialize()
