

extends Node


@export var light: PointLight2D
@export var base_scale: float = 1.0
@export var flicker_intensity: float = 0.1
@export var base_energy: float = 1.0
@export var energy_intensity: float = 0.2

var time: float = 0.0

func _process(delta: float) -> void:
    time += delta
    
    # Layer multiple sine waves at different speeds for organic feel
    var flicker = sin(time * 7.0) * 0.5
    flicker += sin(time * 13.0) * 0.3
    flicker += sin(time * 23.0) * 0.2
    
    # Add subtle randomness on top
    flicker += randf_range(-0.1, 0.1)
    
    light.texture_scale = base_scale + flicker * flicker_intensity
    light.energy = base_energy + flicker * energy_intensity