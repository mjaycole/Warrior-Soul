#Handles the player camera

extends Camera2D

@export var target: CharacterBody2D
@export var base_resolution: Vector2 = Vector2(1920, 1080)
@export var base_zoom: float = 6.0

@export var smoothing_speed = 5.0
@export var offset_y = 2

@export var max_lookahead_distance: float = 50
@export var mouse_influence: float = .3

var target_pos

func _ready():
	update_zoom()
	get_tree().root.size_changed.connect(update_zoom)

func _physics_process(delta: float):
	if not target:
		return
	
	update_target_positions()
	move_camera(delta)


func update_zoom():
	var current_size = get_viewport().get_visible_rect().size
	var scale_factor = min(current_size.x / base_resolution.x, current_size.y / base_resolution.y)
	zoom = Vector2(base_zoom * scale_factor, base_zoom * scale_factor)

func update_target_positions():
	var targ_position = target.global_position
	var mouse_pos = get_global_mouse_position()

	# Get directioni and distance from target to mouse
	var offset = mouse_pos - targ_position

	# Clamp the offset to a max distance
	var clamped_offset = offset.limit_length(max_lookahead_distance)

	# Camera target is player position plus the clamped offset
	target_pos = targ_position + clamped_offset * mouse_influence


func move_camera(delta: float):
	# global_position = lerp(global_position, target_pos, camera_speed * delta)
	global_position = global_position.lerp(target_pos, smoothing_speed * delta)
	global_position = global_position.round() + (Vector2.UP * offset_y)
