

extends EnemyPhysics



func command_freeze():
	enemy_controller.velocity = Vector2.ZERO

func _handle_current_state_physics(delta: float):
	match current_state:
		Enemy.State.PATROLLING:
			_patrol()
		Enemy.State.CHASING:
			_chase()


func _patrol():
	if not enemy_controller.has_destination:
		return

	enemy_controller.velocity.x = enemy_controller.direction * enemy_controller.patrol_walk_speed

func _chase():
	if not enemy_controller.has_player_position:
		return

	enemy_controller.velocity.x = enemy_controller.direction * enemy_controller.chase_speed

