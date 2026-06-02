#Is the fetcher any script can access 

extends Node

var _items_array: Array = []
var _items: Dictionary = {}

func _ready():
	var library: ItemLibrary = preload("res://Resources/ItemLibrary.tres")
	
	for item in library.items:
		_items[item.id] = item
		_items_array.append(item)

func get_all_items() -> Array:
	return _items_array

func get_item(id: String) -> Item:
	return _items.get(id, null)
