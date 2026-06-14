# This handles the player's detection of interactable objects so the player can be prompted

extends Area2D
class_name PlayerInteract


signal interactable_entered(interactable)
signal interactable_exited
signal interactable_interact(interactable: Interactable)

var current_interactable: Interactable



func _ready():
    area_entered.connect(_handle_interact_entered)
    area_exited.connect(_handle_interact_exited)

func command_interact():
    if current_interactable:
        current_interactable.command_interacted(get_parent())

func _handle_interact_entered(body: Area2D):
    if body is Interactable:
        current_interactable = body
        interactable_entered.emit(current_interactable)

func _handle_interact_exited(body: Area2D):
    if body is Interactable:
        if body == current_interactable:
            current_interactable = null
            interactable_exited.emit()

