# Handles communication with the environment library

extends Node
class_name EnviroObjFetcher

static var _objects_array: Array = []
static var _objects: Dictionary = {}

func _ready():
	var library: Environment_Object_Library = preload("res://Resources/Data/environment_object_library.tres")
	
	for object in library.objects:
		_objects[object.id] = object
		_objects_array.append(object)

func get_all_objects() -> Array:
	return _objects_array

static func get_object(id: String) -> Environment_Object:
	return _objects.get(id, null)
