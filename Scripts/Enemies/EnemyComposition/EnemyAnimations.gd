# Handles the animations for the enemy

extends AnimationPlayer
class_name EnemyAnimations


@export var sprite: Sprite2D

var enemy_controller: Enemy
var current_state: Enemy.State

func _ready():
	enemy_controller = get_parent()
	enemy_controller.enemy_state_changed.connect(handle_state_change)

func handle_state_change(new_state: Enemy.State):
	current_state = new_state

	handle_state_switch_animations()

func handle_state_switch_animations():
	pass

func handle_state_animations(delta: float):
	pass

func handle_direction(direction: float):
	if direction < 0:
		sprite.flip_h = false
	elif direction > 0:
		sprite.flip_h = true


# Handling the animations based on the current_state
func handle_idle():
	pass

func handle_walk():
	pass

func handle_chase():
	pass

func handle_attack():
	pass

func handle_death():
	pass