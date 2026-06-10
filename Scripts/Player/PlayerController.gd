#The core of the player controller

extends CharacterBody2D
class_name player_controller

# Signals
signal player_state_changed(new_state)
signal player_use_item(item_compass)

# Sub-Node References
@onready var player_animations = $AnimationPlayer
@onready var player_physics = $Physics
@onready var player_item_use = $"PlayerItemUsage"
@onready var player_damageable: Damageable = $Damageable
@onready var player_audio: PlayerAudio = $PlayerAudio 

# Variables
@export var hurt_time: float = 3

# State Machine
enum State { 
	IDLE, WALKING, SPRINTING, PUSHING, JUMPING, FALLING, 
	DASHING, GRABBING_LEDGE, CLIMBING, USING_ITEM, HURT, DEAD }

var current_state = State.IDLE
var current_item_use: Item

#region Godot Functions
#Godot Functions
func _ready():
	_setup_core_listeners()
	_setup_physics()
	_setup_item_use()
	_setup_damageable()

	player_state_changed.emit(current_state)

func _input(event: InputEvent):
	if not Core.input_enabled:
		return
	
	if event.is_action_pressed("Jump"):
		if can_go_to_state(State.JUMPING):
			player_physics.command_jump()
	if event.is_action_pressed("Dash"):
		if can_go_to_state(State.DASHING):
			player_physics.command_dash()		
	if event.is_action_pressed("Sprint"):
		player_physics.command_sprint(true)
	if event.is_action_released("Sprint"):
		player_physics.command_sprint(false)
	if event.is_action_pressed("RightHandItem"):
		if can_go_to_state(State.USING_ITEM):
			player_item_use.command_use("right_hand", self)


func _physics_process(delta: float):
	player_animations.handle_animations(player_physics.last_direction)
	player_physics.calculated_physics(delta)
	player_audio.handle_audio(delta)

#endregion

#region Setup
func _setup_core_listeners():
	#TODO - Move this over to game initialization logic	
	Core.player_data.inventory.set_active_item("right_hand", Core.player_data.inventory.items[0])
	Core.input_availability_changed.connect(handle_input_availability_changed)
	Core.player_data.stats.player_stats_changed.connect(player_physics.command_pull_latest_stats)

func _setup_physics():
	player_physics.command_pull_latest_stats()
	player_physics.started_walking.connect(handle_started_walking)
	player_physics.stopped_walking.connect(handle_stopped_walking)
	player_physics.left_ground.connect(handle_left_ground)
	player_physics.landed.connect(handle_landed)
	player_physics.hit_wall.connect(handle_hit_wall)
	player_physics.left_wall.connect(handle_left_wall)
	player_physics.ledge_detected.connect(handle_ledge_detected)
	player_physics.jump_started.connect(handle_jump_started)
	player_physics.jump_peaked.connect(handle_jump_peaked)
	player_physics.jump_landed.connect(handle_jump_landed)
	player_physics.dash_started.connect(handle_dash_started)
	player_physics.dash_completed.connect(handle_dash_completed)
	player_physics.climb_started.connect(handle_climb_started)
	player_physics.climb_completed.connect(handle_climb_completed)

func _setup_item_use():
	player_item_use.command_refresh_items()
	player_item_use.item_use.connect(handle_item_use)
	player_item_use.item_use_completed.connect(handle_item_use_completed)

func _setup_damageable():
	player_damageable.damage_taken.connect(_on_damage_taken)

#endregion

#region State Changing
#State Changing
func switch_state(new_state: State, ignore_state_check: bool = false):
	if not ignore_state_check:
		if not can_go_to_state(new_state):
			return

	current_state = new_state
	player_state_changed.emit(current_state)

	match current_state:
		State.USING_ITEM:
			player_physics.command_freeze()
		State.HURT:
			player_physics.command_freeze()

			await get_tree().create_timer(hurt_time).timeout

			reset_state()
		_: 
			player_physics.command_unfreeze()

	# print("Current State: ", current_state)

func can_go_to_state(state: State) -> bool:
	# Dead is a terminal state - can't leave it
	if current_state == State.DEAD:
		return false

	match state:
		State.IDLE, State.WALKING, State.SPRINTING, State.PUSHING, State.FALLING: 
			return current_state != State.USING_ITEM

		State.JUMPING:
			return current_state not in [
				State.USING_ITEM,
				State.DASHING,
				State.CLIMBING,
				State.HURT
			]

		State.DASHING: 
			return current_state not in [
				State.USING_ITEM,
				State.DASHING,
				State.GRABBING_LEDGE,
				State.CLIMBING,
				State.HURT
			]

		State.GRABBING_LEDGE:
			return current_state not in [
				State.USING_ITEM,
				State.GRABBING_LEDGE,
				State.CLIMBING,
				State.HURT
			]

		State.CLIMBING:
			return current_state in [
				State.GRABBING_LEDGE
			]

		State.USING_ITEM:
			return current_state not in [
				State.USING_ITEM,
				State.DASHING,
				State.GRABBING_LEDGE,
				State.CLIMBING,
				State.HURT
			]
		
		State.HURT:
			return current_state not in [
				State.HURT
			]

		State.DEAD: 
			return true
	
	# Any unhandled state is blocked - add new states explicitly above
	return false

func reset_state():
	# Override can_go_to_state by setting directly since we're resetting
	var new_state: State

	if is_on_floor():
		if velocity.x != 0:
			if player_physics.sprinting:
				new_state = State.SPRINTING
			else:
				new_state = State.WALKING
		else: 
			new_state = State.IDLE
	else:
		if velocity.y < 0:
			new_state = State.JUMPING
		else:
			new_state = State.FALLING

	switch_state(new_state, true)


#endregion

#region Movement Listeners
func handle_input_availability_changed(available: bool):
	if available:
		player_physics.command_unfreeze()
	else:
		player_physics.command_freeze()

func handle_started_walking(is_sprinting: bool):
	if is_sprinting:
		switch_state(State.SPRINTING)
	else:
		switch_state(State.WALKING)

func handle_stopped_walking():
	switch_state(State.IDLE)

func handle_left_ground():
	switch_state(State.FALLING)

func handle_landed():
	player_audio.handle_landed()
	reset_state()

func handle_jump_started():
	print("Jump started")
	switch_state(State.JUMPING)

func handle_jump_peaked():
	switch_state(State.FALLING)

func handle_jump_landed():
	reset_state()

func handle_hit_wall():
	switch_state(State.PUSHING)

func handle_left_wall():
	reset_state()

func handle_ledge_detected():
	switch_state(State.GRABBING_LEDGE)

func handle_dash_started():
	switch_state(State.DASHING)

func handle_dash_completed():
	reset_state()

func handle_climb_started():
	switch_state(State.CLIMBING)

func handle_climb_completed(): 
	reset_state()

func handle_item_use_completed():
	current_item_use = null
	reset_state()

func handle_attack_finished():
	print("Called finished")
	reset_state()

#endregion

#region Item Usage Listeners
#Item Usage Listeners
func handle_item_use(item_compass: String):
	if not can_go_to_state(State.USING_ITEM):
		return

	var item: Item = Core.player_data.inventory.active_items[item_compass]

	if item == null:
		return

	current_item_use = item
	player_animations.handle_item_use()
	player_use_item.emit(item.id)

	switch_state(State.USING_ITEM)

#endregion

#region Health Listeners
func _on_damage_taken(source: Node, amount: float):
	switch_state(State.HURT)
#endregion
