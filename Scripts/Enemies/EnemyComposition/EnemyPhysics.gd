# This is the physics controller for enemies

extends Node2D
class_name  EnemyPhysics


@export_group("Variables")
@export var use_gravity: bool = true

var enemy_controller: Enemy
var current_state: Enemy.State
var frozen: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	enemy_controller = get_parent()
	enemy_controller.enemy_state_changed.connect(_handle_state_change)

func handle_physics(delta: float):
	_handle_current_state_physics(delta)

	if use_gravity:
		if not enemy_controller.is_on_floor():
			enemy_controller.velocity.y += gravity * delta
	
	enemy_controller.move_and_slide()

func command_freeze():
	frozen = true

func command_unfreeze():
	frozen = false



func _handle_state_change(new_state: Enemy.State):
	current_state = new_state

func _handle_current_state_physics(delta: float):
	pass
