#Handles listening for input and producing signals for it

extends Node

#Signals
signal item_use(item_compass) #item_compass is telling if it was the - right, left, north, or south item used

func _input(event: InputEvent):
	if event.is_action_pressed("RightHandItem"):
		item_use.emit("right_hand")
