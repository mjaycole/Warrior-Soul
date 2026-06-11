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
    handle_state_audio(delta)

func handle_state_change(new_state: Enemy.State):
    current_state = new_state

    match current_state:
        Enemy.State.DEAD:
            AudioManagerNode.play_effect_at_point(enemy_data.death_sound, .15, 1, enemy_controller.global_position)

func handle_state_audio(delta: float):
    return