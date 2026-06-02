#Handles the player's physics

extends Node2D

signal walk_input(is_sprinting)
signal idle_input
signal jump_input(is_jumping)
signal jump_finish
signal dash_input
signal dash_finish
signal push_input(pushing)
signal ledge_grabbed(grabbed)
signal climbing_input
signal climbing_finished

var SPEED = 100.0
var JUMP_VELOCITY = -300.0
var SPRINT_MODIFIER = 1.5
var COYOTE_TIME = 1.0
var DASH_VELOCITY = -200.0
var DASH_TIME = .5
var PUSH_SPEED = 100.0
var CLIMB_TIME = .25

var current_sprint_modifier = 1

var character_body
var player_state
@onready var raycasts_parent = $"../Raycasts"
@onready var wall_check_ray = $"../Raycasts/WallCheck"
@onready var ledge_grab_check_ray = $"../Raycasts/LedgeGrabCheck"
@onready var ledge_grab_collision = $"../Raycasts/LedgeDetection"

var direction: float = -1
var last_direction: int = -1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumping: bool = false
var was_on_floor: bool = true
var in_air_lose_speed: float = 10
var time_off_platform = 0
var sprinting: bool = false
var dashing: bool = false
var against_wall: bool = false
var grabbable_ledge: bool = false
var on_ledge: bool = false
var climbing: bool = false
var climb_timer: float = 0.0
var climb_position

func _ready():
	SPEED = get_meta("Speed")
	SPRINT_MODIFIER = get_meta("SprintModifier")
	JUMP_VELOCITY = get_meta("Jump")
	COYOTE_TIME = get_meta("CoyoteTime")
	DASH_VELOCITY = get_meta("DashModifier")
	DASH_TIME = get_meta("DashTime")
	PUSH_SPEED = get_meta("PushSpeed")
	CLIMB_TIME = get_meta("ClimbTime")
	
	character_body = get_parent()
	character_body.player_state_changed.connect(handle_state_change)
	character_body.player_use_item.connect(handle_item_used)

	ledge_grab_collision.body_entered.connect(_on_ledge_area_entered)
	ledge_grab_collision.body_exited.connect(_on_ledge_area_exited)
	


func _process(delta: float):		
	handle_coyote_time(delta)

func _input(event: InputEvent):	
	if event.is_action_pressed("Jump"):
		jump()
	
	if event.is_action_pressed("Dash"):
		dash()
		
	if event.is_action_pressed("Sprint"):
		sprinting = true
		current_sprint_modifier = SPRINT_MODIFIER
	elif event.is_action_released("Sprint"):
		sprinting = false
		current_sprint_modifier = 1

func handle_state_change(new_state: player_controller.State):
	player_state = new_state

func calculated_physics(delta):
	direction = Input.get_axis("MoveLeft", "MoveRight")
	
	if player_state == player_controller.State.ATTACKING:
		apply_gravity(delta)

		character_body.move_and_slide()
		return
		
	if direction != 0 && not on_ledge && not climbing:
		last_direction = direction
	
	apply_gravity(delta)
	wall_check()
	handle_movement()
	handle_climbing(delta)
	handle_fall_state(delta)
	
	character_body.move_and_slide()

func apply_gravity(delta):
	if on_ledge or climbing:
		return
		
	if not character_body.is_on_floor():
		character_body.velocity.y += gravity * delta

func wall_check():
	if on_ledge or climbing:
		return
	
	raycasts_parent.scale.x = -last_direction	
	against_wall = wall_check_ray.is_colliding()

func _on_ledge_area_entered(body):
	grabbable_ledge = not ledge_grab_check_ray.is_colliding()

func _on_ledge_area_exited(body):
	grabbable_ledge = false

func handle_movement():
	if dashing or climbing:
		return
		
	if on_ledge:
		return
			
	if against_wall && direction != 0:
		push_input.emit(true)		
		character_body.velocity.x = direction * PUSH_SPEED
		
		if character_body.velocity.y > 0 && grabbable_ledge && not on_ledge && not climbing:
			on_ledge = true
			
			ledge_grabbed.emit(on_ledge)
			character_body.velocity = Vector2.ZERO
		return
	
	if against_wall && direction == 0:
		push_input.emit(false)

		if character_body.velocity.y > 0 && grabbable_ledge && not on_ledge && not climbing:
			on_ledge = true
			
			ledge_grabbed.emit(on_ledge)
			character_body.velocity = Vector2.ZERO
		return
		
	character_body.velocity.x = direction * SPEED * current_sprint_modifier

	if character_body.is_on_floor() and not jumping:
		if direction != 0:
			walk_input.emit(sprinting)
		else:
			idle_input.emit()

func jump():	
	if dashing or climbing:
		return
	
	if on_ledge:
		if last_direction == direction:
			jump_on_ledge()
		else:
			apply_jump()
		return
	
	apply_jump()

func apply_jump():
	if character_body.is_on_floor() or time_off_platform < COYOTE_TIME or on_ledge:
		character_body.velocity.y = JUMP_VELOCITY
		
		on_ledge = false
		jumping = true
		jump_input.emit(jumping)

func handle_item_used(item_id: String):
	var item_used = ItemLibraryFetcher.get_item(item_id)
	
	var weapon = item_used as Weapon
	
	if weapon:
		character_body.velocity.x = weapon.momentum_force * last_direction

func jump_on_ledge():	
	on_ledge = false
	ledge_grabbed.emit(false)	
	climbing = true
	climb_timer = 0.0
	climbing_input.emit()
	
	climb_position = character_body.global_position + Vector2(last_direction * 7, -11)

func handle_climbing(delta: float):
	if not climbing:
		return
	
	climb_timer += delta
	character_body.global_position = lerp(character_body.global_position, climb_position, delta * 7)
	
	if climb_timer >= CLIMB_TIME:
		character_body.velocity = Vector2.ZERO
		climbing = false
		climbing_finished.emit()
		idle_input.emit()

func handle_fall_state(delta: float):
	if climbing or on_ledge:
		return
		
	var on_floor = character_body.is_on_floor()
	
	if not on_floor:
		if character_body.velocity.y > 0:
			jump_input.emit(false)
			if character_body.velocity.x != 0:
				character_body.velocity.x = lerpf(character_body.velocity.x, 0.0, delta * in_air_lose_speed)
	elif jumping and not was_on_floor:
		jumping = false
		jump_finish.emit()
	
	var changed = was_on_floor != on_floor
	
	was_on_floor = on_floor
	
	if changed and not on_floor and not jumping:
		time_off_platform = 0

func handle_coyote_time(delta: float):
	if time_off_platform < COYOTE_TIME:
		time_off_platform += delta

func dash():
	if character_body.is_on_floor() and not dashing:
		character_body.velocity.x = DASH_VELOCITY * -last_direction
		
		dashing = true
		dash_input.emit()
		dash_time()

func dash_time():
	await get_tree().create_timer(DASH_TIME).timeout
	dashing = false
	dash_finish.emit()	
