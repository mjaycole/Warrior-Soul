#Handles the in game hud

extends Control
class_name InGameHUD

#Active Items UI
@onready var right_hand_icon = $CanvasLayer/ActiveItems/RightHand/ItemIcon

func _ready():
	Core.player_data.inventory.active_items_changed.connect(handle_active_items_changed)
	
func handle_active_items_changed():
	if Core.player_data.inventory.active_items["right_hand"]:
		right_hand_icon.texture = Core.player_data.inventory.active_items["right_hand"].icon
