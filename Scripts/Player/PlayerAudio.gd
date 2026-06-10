# Handles playing all the sound effects for the player controller

extends Node2D
class_name  PlayerAudio

var player_state
var character_controller

# Footsteps
@export var footsteps: Array[AudioStream]
@export var time_between_steps: float = .25
@export var time_between_sprint_steps: float = .2
@export var footstep_volume: float
var playing_footstep: bool = false

# Jumping and falling
@export var jump: AudioStream
@export var jump_volume: float = .2
@export var landed: AudioStream
@export var landed_volume: float = .2

# Dashing
@export var dash: AudioStream
@export var dash_volume: float = .2

# Ledge and Climbing
@export var ledge_grab: AudioStream
@export var ledge_grab_volume: float = .2
@export var climb: AudioStream
@export var climb_volume: float = .2

func _ready():
	character_controller = get_parent()
	character_controller.player_state_changed.connect(handle_state_change)

func handle_state_change(new_state: player_controller.State):
	player_state = new_state
	handle_audio_state_switch()

#Handles the audio for the current state
func handle_audio_state_switch():
	match player_state:
		player_controller.State.USING_ITEM: handle_item_use()
		player_controller.State.DASHING: handle_dash()
		player_controller.State.JUMPING: handle_jump()
		player_controller.State.GRABBING_LEDGE: handle_ledge_grab()
		player_controller.State.CLIMBING: handle_climb()

func handle_audio(delta: float):	
	match player_state:
		player_controller.State.WALKING: handle_walk()
		player_controller.State.SPRINTING: handle_sprint()


func handle_walk():
	if not playing_footstep:
		AudioManagerNode.play_effect(footsteps[randi_range(0, footsteps.size() - 1)], footstep_volume)
		handle_footstep_time(time_between_steps)

func handle_sprint():
	if not playing_footstep:
		AudioManagerNode.play_effect(footsteps[randi_range(0, footsteps.size() - 1)], footstep_volume)
		handle_footstep_time(time_between_sprint_steps)

func handle_footstep_time(time: float):
	playing_footstep = true
	await get_tree().create_timer(time).timeout
	playing_footstep = false

func handle_dash():
	AudioManagerNode.play_effect(dash, dash_volume)

func handle_jump():
	AudioManagerNode.play_effect(jump, jump_volume)

func handle_ledge_grab():
	AudioManagerNode.play_effect(ledge_grab, ledge_grab_volume)

func handle_climb():
	AudioManagerNode.play_effect(climb, climb_volume)

func handle_landed():
	AudioManagerNode.play_effect(landed, landed_volume)

func handle_item_use():
	if character_controller.current_item_use != null && character_controller.current_item_use.use_sound != null:
		AudioManagerNode.play_effect(character_controller.current_item_use.use_sound, character_controller.current_item_use.use_volume)