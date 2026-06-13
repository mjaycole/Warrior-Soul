# Handles the audio for the enemy

extends  Node2D
class_name EnemyAudio



var enemy_controller: Enemy
var enemy_data: EnemyData
var current_state: Enemy.State



func initialize(data: EnemyData):
	enemy_data = data
	enemy_controller = get_parent()

	enemy_controller.enemy_state_changed.connect(handle_state_change)

func _process(delta: float):
	handle_state_audio()

func handle_state_change(new_state: Enemy.State):
	current_state = new_state

func handle_state_audio():
	pass
