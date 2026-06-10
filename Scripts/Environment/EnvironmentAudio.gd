

extends AudioStreamPlayer2D

@export var volume: float = .5

func _ready():
	volume_db = linear_to_db(AudioManagerNode.effects_volume * volume)


	
