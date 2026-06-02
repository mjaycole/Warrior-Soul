#Handles loading in the appropriate node for the game world

extends Node
class_name  GameWorldManager

var current_scene

func _ready():
	Core.register_game_world_manager(self)

func load_sandbox():
	if current_scene:
		current_scene.queue_free()
		
	current_scene = preload("res://Nodes/sandbox.tscn").instantiate()
	add_child(current_scene)
