# The node that allows the player to detect when something is interactable

extends Area2D
class_name Interactable


signal player_interacted(_player)

@export var requires_player_input: bool = false
var player: player_controller

func _ready():
    body_entered.connect(_handle_body_entered)
    body_exited.connect(_handle_body_exited)

func command_interacted(_player: player_controller):
    player_interacted.emit(_player)

func _handle_body_entered(body: Node):
    if body is player_controller:
        print("Detected player interact")
        player = body

        if not requires_player_input:
            command_interacted(player)

func _handle_body_exited(body: Node):
    if body is player_controller:
        player = null

