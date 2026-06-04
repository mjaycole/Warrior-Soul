#Handles the ItemBehaviors on the player node, telling them to Use and listening for completion

extends Node

#Signals
signal item_use(item_compass) #item_compass is telling if it was the - right, left, north, or south item used
signal item_use_completed


#Ready vars
@onready var item_parent = $ItemSpawn

var active_item_data: Dictionary
var active_item_behaviors: Dictionary #String item_compass, ItemBehavior item_behavior

func command_refresh_items():
	_clear_existing_item_behavior_nodes()

	active_item_data = Core.player_data.inventory.active_items

	for slot in active_item_data.keys():
		var item = active_item_data[slot]
		if item:
			_spawn_item_bahavior_nodes(item, slot)
	
func command_use(slot: String, player: player_controller):
	if not active_item_behaviors.has(slot):
		return

	if active_item_behaviors[slot]:
		active_item_behaviors[slot].use(player)
		item_use.emit(slot)

func _clear_existing_item_behavior_nodes():
	for item in active_item_behaviors.values():
		item.queue_free()
	
	active_item_behaviors.clear()


func _spawn_item_bahavior_nodes(item: Item, slot: String):
	var new_item_behavior = item.item_behavior.instantiate()

	if new_item_behavior:
		item_parent.add_child(new_item_behavior)
		active_item_behaviors[slot] = new_item_behavior
		active_item_behaviors[slot].item_data = item
		active_item_behaviors[slot].item_use_completed.connect(_handle_item_finish_use)

func _handle_item_finish_use():
	item_use_completed.emit()
