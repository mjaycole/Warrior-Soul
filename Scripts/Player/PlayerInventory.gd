#Handles managing the player's inventory

extends Resource
class_name PlayerInventory

#Signals
signal item_added(item: Item)
signal item_removed(item: Item)
signal active_items_changed

#Variables
@export var items: Array[Item] = []
@export var max_slots: int = 10

@export var active_items: Dictionary = {
    "right_hand": null,
    "left_hand": null,
    "item_north": null,
    "item_south": null
}


#Core Item Lookup
func add_item(item: Item) -> bool:
	if items.size() >= max_slots:
		return false
	
	items.append(item)
	item_added.emit(item)
	return true

func remove_item(item: Item):
	items.erase(item)
	item_removed.emit(item)
	
func has_item(item: Item) -> bool:
	for _item in items:
		if _item.id == item.id:
			return true
			
	return false

func has_item_name(item_name: String) -> bool:
	for _item in items:
		if _item.item_name == item_name:
			return true
			
	return false


#Active Items
func set_active_item(slot: String, item: Item):
	active_items[slot] = item

	active_items_changed.emit()
