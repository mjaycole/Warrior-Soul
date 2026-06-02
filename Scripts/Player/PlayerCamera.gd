#Handles the player camera

extends Camera2D

@export var target: CharacterBody2D
@export var base_resolution: Vector2 = Vector2(1920, 1080)
@export var base_zoom: float = 6.0

var smoothing_speed = 5.0
var offset_y = 2

func _ready():
	update_zoom()
	get_tree().root.size_changed.connect(update_zoom)

func update_zoom():
	var current_size = get_viewport().get_visible_rect().size
	var scale_factor = min(current_size.x / base_resolution.x, current_size.y / base_resolution.y)
	zoom = Vector2(base_zoom * scale_factor, base_zoom * scale_factor)

func _physics_process(delta: float):
	if not target:
		return
	global_position = global_position.lerp(target.global_position, smoothing_speed * delta)
	global_position = global_position.round() + (Vector2.UP * offset_y)
