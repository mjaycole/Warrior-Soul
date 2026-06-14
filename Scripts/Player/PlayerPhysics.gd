# Handles the player's physics - reports physical events, executes movement commands

extends Node2D

# Physical events - PlayerController listens and decides state
signal started_walking(is_sprinting: bool)
signal stopped_walking
signal left_ground
signal landed
signal hit_wall
signal left_wall
signal ledge_detected
signal jump_started
signal jump_peaked
signal jump_landed
signal dash_started
signal dash_completed
signal climb_started
signal climb_completed

# Physics constants
@export var SPEED = 100.0
@export var JUMP_VELOCITY = -300.0
@export var SPRINT_MODIFIER = 1.5
@export var COYOTE_TIME = 1.0
@export var DASH_VELOCITY = -200.0
@export var DASH_TIME = .5
@export var PUSH_SPEED = 100.0
@export var CLIMB_TIME = .25
@export var IN_AIR_LOSE_SPEED = 15

# Internal state - physics only, no game state awareness
var character_body: CharacterBody2D
var direction: float = 0.0
var last_direction: int = -1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_sprint_modifier: float = 1.0
var sprinting: bool = false
var jumping: bool = false
var jump_has_peaked: bool = false
var dashing: bool = false
var frozen: bool = false
var on_ledge: bool = false
var climbing: bool = false
var against_wall: bool = false
var was_against_wall: bool = false
var was_on_floor: bool = true
var time_off_platform: float = 0.0
var climb_timer: float = 0.0
var climb_position: Vector2
var pushable_detected: bool = false
var current_pushable: Pushable

@onready var raycasts_parent = $"../Raycasts"
@onready var wall_check_ray = $"../Raycasts/WallCheck"
@onready var ledge_top_ray: RayCast2D = $"../Raycasts/LedgeTopRay"
@onready var pushable_check_ray = $"../Raycasts/PushableCheck"


#region Godot Functions

func _ready() -> void:
	character_body = get_parent()
	character_body.player_use_item.connect(_on_item_used)

func _process(delta: float) -> void:
	_handle_coyote_time(delta)

#endregion

#region Commands - Called by PlayerController

func calculated_physics(delta: float) -> void:
	if frozen:
		_apply_gravity(delta)
		character_body.move_and_slide()
		return

	direction = Input.get_axis("MoveLeft", "MoveRight")

	if direction != 0 and not on_ledge and not climbing:
		last_direction = direction

	_apply_gravity(delta)
	_pushable_check()
	_wall_check()
	_handle_movement(delta)
	_handle_climbing(delta)
	_handle_fall_state(delta)

	character_body.move_and_slide()

func command_pull_latest_stats():
	SPEED = Core.player_data.stats.get_movement_stat("speed")
	JUMP_VELOCITY = Core.player_data.stats.get_movement_stat("jump")
	SPRINT_MODIFIER = Core.player_data.stats.get_movement_stat("sprint")
	DASH_VELOCITY = Core.player_data.stats.get_movement_stat("dash")

func command_jump() -> void:
	if dashing or climbing:
		return

	if on_ledge:
		if last_direction == direction:
			_jump_on_ledge()
		else:
			_apply_jump()
		return

	_apply_jump()

func command_dash() -> void:
	if character_body.is_on_floor() and not dashing:
		character_body.velocity.x = DASH_VELOCITY * -last_direction
		dashing = true
		dash_started.emit()
		_dash_timer()

func command_sprint(active: bool) -> void:
	sprinting = active
	current_sprint_modifier = SPRINT_MODIFIER if active else 1.0

func command_freeze() -> void:
	frozen = true

func command_unfreeze() -> void:
	frozen = false

func command_apply_momentum(force: float, direction: float) -> void:
	character_body.velocity.x = force * direction

#endregion


#region Internal Physics - Private

func _apply_gravity(delta: float) -> void:
	if on_ledge or climbing:
		return
	if not character_body.is_on_floor():
		character_body.velocity.y += gravity * delta

func _wall_check() -> void:
	if on_ledge or climbing:
		return
	raycasts_parent.scale.x = -last_direction
	against_wall = wall_check_ray.is_colliding()

func _pushable_check():
	pushable_detected = pushable_check_ray.is_colliding()

func _handle_movement(delta: float) -> void:
	if dashing or climbing or on_ledge:
		return

	if character_body.velocity.y > 0 and ledge_top_ray.is_colliding() and not on_ledge and not climbing:
		_grab_ledge()
		return

	if against_wall and direction != 0:
		if not was_against_wall:
			was_against_wall = true
			hit_wall.emit()
	
	if was_against_wall and (not against_wall or direction == 0):
		was_against_wall = false
		left_wall.emit()
		if current_pushable:
			current_pushable.on_pushed(Vector2.ZERO, 0)
			current_pushable = null
	
	if against_wall and direction != 0:
		character_body.velocity.x = direction * PUSH_SPEED
		_handle_push_pushable_object(delta)
		return

	character_body.velocity.x = direction * SPEED * current_sprint_modifier
	
	if character_body.is_on_floor() and not jumping:
		if direction != 0:
			started_walking.emit(sprinting)
		else:
			stopped_walking.emit()

func _grab_ledge() -> void:
	on_ledge = true
	character_body.velocity = Vector2.ZERO

	if ledge_top_ray.is_colliding():
		var ledge_top = ledge_top_ray.get_collision_point()
		climb_position = Vector2(
			ledge_top.x - (last_direction * 4),
			ledge_top.y + 8
		)
		character_body.global_position = climb_position

	ledge_detected.emit()

func _apply_jump() -> void:
	if character_body.is_on_floor() or time_off_platform < COYOTE_TIME or on_ledge:
		character_body.velocity.y = JUMP_VELOCITY
		on_ledge = false
		jumping = true
		jump_started.emit()

func _jump_on_ledge() -> void:
	on_ledge = false
	climb_started.emit()
	climbing = true
	climb_timer = 0.0
	climb_position = character_body.global_position + Vector2(last_direction * 7, -11)

func _handle_climbing(delta: float) -> void:
	if not climbing:
		return

	climb_timer += delta
	character_body.global_position = lerp(
		character_body.global_position,
		climb_position,
		delta * 7
	)

	if climb_timer >= CLIMB_TIME:
		character_body.velocity = Vector2.ZERO
		climbing = false
		climb_completed.emit()

func _handle_fall_state(delta: float) -> void:
	if climbing or on_ledge:
		return

	var on_floor = character_body.is_on_floor()

	if not on_floor:
		if character_body.velocity.y > 0:
			if not jump_has_peaked:
				jump_peaked.emit()
				jump_has_peaked = true
			if character_body.velocity.x != 0:
				character_body.velocity.x = lerpf(
					character_body.velocity.x, 
					0.0, 
					delta * IN_AIR_LOSE_SPEED
				)
	elif jumping and not was_on_floor:
		jumping = false
		jump_has_peaked = false
		jump_landed.emit()

	if on_floor && not was_on_floor:
		landed.emit()
	
	var changed = was_on_floor != on_floor
	was_on_floor = on_floor

	if changed and not on_floor and not jumping:
		time_off_platform = 0

func _handle_coyote_time(delta: float) -> void:
	if time_off_platform < COYOTE_TIME:
		time_off_platform += delta

func _dash_timer() -> void:
	await get_tree().create_timer(DASH_TIME).timeout
	dashing = false
	dash_completed.emit()

func _on_item_used(item_id: String) -> void:
	var item = ItemLibraryFetcher.get_item(item_id)
	var weapon = item as Weapon
	if weapon:
		var mouseDirection = character_body.get_global_mouse_position()
		if mouseDirection.x > global_position.x:
			mouseDirection = 1
		else:
			mouseDirection = -1

		command_apply_momentum(weapon.momentum_force, mouseDirection)

func _handle_push_pushable_object(delta: float):
	if current_pushable == null:
		current_pushable = pushable_check_ray.get_collider() as Pushable

	if current_pushable != null:
		current_pushable.on_pushed(Vector2(direction, 0), PUSH_SPEED)
#endregion
