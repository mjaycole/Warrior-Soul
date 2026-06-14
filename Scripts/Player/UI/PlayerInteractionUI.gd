# This handles showing the player interaction prompt

class_name PlayerInteractionUI extends Control



@onready var player: player_controller = get_parent().get_parent()

@export var offset: Vector2

var interact: PlayerInteract

func _ready():
    visible = false
    interact = player.get_node("PlayerInteract")
    interact.interactable_entered.connect(_on_interactable_entered)
    interact.interactable_exited.connect(_on_interactable_exited)

func _process(delta: float):
    if visible:
        var screen_pos = get_viewport().get_canvas_transform() * player.global_position
        position = screen_pos + offset

func _on_interactable_entered(interactable: Interactable):
    visible = true;

func _on_interactable_exited():
    visible = false

func _on_interactable_interact(interactable: Interactable):
    visible = false
