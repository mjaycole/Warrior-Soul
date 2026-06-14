# This handles the player's detection of interactable objects so the player can be prompted

extends Area2D
class_name PlayerInteract


signal interactable_entered(interactable)
signal interactable_exited
signal interactable_interact(interactable: Interactable)

var current_interactable: Interactable
var interactables_in_range: Array[Interactable]


func _ready():
    area_entered.connect(_handle_interact_entered)
    area_exited.connect(_handle_interact_exited)

func command_interact():
    if current_interactable:
        current_interactable.command_interacted(get_parent())

func _handle_interact_entered(body: Area2D):
    if body is Interactable:
        current_interactable = body
        interactables_in_range.append(current_interactable)
        interactable_entered.emit(current_interactable)

func _handle_interact_exited(body: Area2D):
    if body is Interactable:
        interactables_in_range.erase(body)

        if interactables_in_range.size() <= 0:
            interactable_exited.emit()
        else:
            if body == current_interactable:
                current_interactable = null

                if interactables_in_range.size() > 0:
                    current_interactable = interactables_in_range[0]
                    interactable_entered.emit(current_interactable)

