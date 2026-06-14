# Handles the player requesting to go to a new game world

extends Node2D
class_name GameWorldTransition

signal transition_game_world_request(new_game_world: String)

@export var interactable: Interactable
@export var next_game_world_name: String


func _ready():
    if interactable:
        interactable.player_interacted.connect(_handle_interacted)


func _handle_interacted(player: player_controller):
    transition_game_world_request.emit(next_game_world_name)