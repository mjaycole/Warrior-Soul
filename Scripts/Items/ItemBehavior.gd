#Attached to an item node that the player equips and controls by PlayerController

extends Node
class_name ItemBehavior

signal item_use_completed

var item_data: Item
var timer_node: Timer

func _ready():
    timer_node = Timer.new()
    timer_node.one_shot = true
    timer_node.timeout.connect(use_completed)
    add_child(timer_node)

func use(player: player_controller):
    pass

func use_completed():
    pass

func equipped(player: player_controller):
    pass

func unequipped():
    pass