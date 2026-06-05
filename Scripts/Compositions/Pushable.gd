extends Area2D
class_name Pushable

signal pushed_started(direction, force, weight)

@export var weight: float = 1
var character_body: CharacterBody2D

func _ready():
	character_body = get_parent() as CharacterBody2D
	if character_body == null:
		print("Pushable object does not have a character body parent")


func on_pushed(direction: Vector2, force: float):
	if character_body == null:
		return
	
	pushed_started.emit(direction, force, weight)