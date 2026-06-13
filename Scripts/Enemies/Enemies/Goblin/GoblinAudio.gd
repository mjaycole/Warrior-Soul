# Handles the audio for the goblin

extends EnemyAudio



var playing_footstep: bool = false
@export var footsteps: Array[AudioStream]
@export var footstep_volume: float
@export var time_between_steps: float
@export var time_between_sprint_steps: float



func handle_state_change(new_state: Enemy.State):
	super.handle_state_change(new_state)
	
	match current_state:
		Enemy.State.ATTACKING:
			AudioManagerNode.play_effect_at_point(enemy_data.attack_sound, .15, 1, enemy_controller.global_position)
		Enemy.State.DEAD:
			AudioManagerNode.play_effect_at_point(enemy_data.death_sound, .15, 1, enemy_controller.global_position)

func handle_state_audio():
	match current_state:
		Enemy.State.PATROLLING: handle_walk()
		Enemy.State.CHASING: handle_sprint()

func handle_walk():
	if not playing_footstep:
		AudioManagerNode.play_effect_at_point(footsteps[randi_range(0, footsteps.size() - 1)], footstep_volume, 1, global_position)
		handle_footstep_time(time_between_steps)

func handle_sprint():
	if not playing_footstep:
		AudioManagerNode.play_effect_at_point(footsteps[randi_range(0, footsteps.size() - 1)], footstep_volume, 1, global_position)
		handle_footstep_time(time_between_sprint_steps)

func handle_footstep_time(time: float):
	playing_footstep = true
	await get_tree().create_timer(time).timeout
	playing_footstep = false