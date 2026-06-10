

extends AudioStreamPlayer2D

@export var volume: float = .5

func _ready():
	volume_db = linear_to_db(volume * AudioManagerNode.master_volume * AudioManagerNode.effects_volume)


	
