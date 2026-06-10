

extends Node
class_name AudioManager

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var effects_parent: Node = $EffectsParent

@export var master_volume: float = .5
@export var music_volume: float = .5
@export var effects_volume: float = .5

@export var effects_players: Array[AudioStreamPlayer]

func play_music(stream: AudioStream):
	if music_player.stream:
		if music_player.stream == stream:
			return #Already playing, don't restart
	music_player.stream = stream
	music_player.play()

func stop_music():
	music_player.stop()

func play_effect(stream: AudioStream, volume: float = 1, pitch: float = 1):
	for player in effects_players:
		if not player.playing:
			player.volume_db = linear_to_db(volume * master_volume * effects_volume) 
			player.stream = stream
			player.play()
			return
	
	# Ran out of players, create a new one
	var new_player = AudioStreamPlayer.new()

	effects_parent.add_child(new_player)
	effects_players.append(new_player)

	new_player.volume_db = linear_to_db(volume* master_volume * effects_volume)
	new_player.stream = stream
	new_player.play()
