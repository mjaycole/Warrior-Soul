

extends Node
class_name AudioManager

@onready var music_player: AudioStreamPlayer = $MusicPlayer

func play_music(stream: AudioStream):
	if music_player.stream:
		if music_player.stream == stream:
			return #Already playing, don't restart
	music_player.stream = stream
	music_player.play()

func stop_music():
	music_player.stop()
