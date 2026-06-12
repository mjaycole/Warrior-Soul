# Handles the state machine for Goblin grunt

extends Enemy


# Patrolling and idle
@export var min_idle: float = 3
@export var max_idle: float = 3
@export var patrol_range: float
@export var patrol_walk_speed: float

# Player detection
@onready var player_check_ray: RayCast2D = $Resources/PlayerDetect
@onready var hurtbox: Hurtbox = $Hurtbox
@export var omniscent: bool = false #Can see in front AND behind them

# Attacking
@export var chase_speed: float
@export var attack_range: float = 2
@export var attack_time: float = 1.5

var starting_position
var destination_position: Vector2
var has_destination: bool = false
var direction: float = -1
var sees_player: bool = false
var player_position: Vector2
var has_player_position: bool = false

# Godot functions
func _ready():
	super._ready()

func _process(delta: float):
	handle_current_state()

	player_check_ray.scale.x = -direction

	player_check()
	

func _physics_process(delta: float):
	super._physics_process(delta)

	handle_current_state_physics(delta)

	animations.handle_direction(direction)

func initialize():
	super.initialize()

	hurtbox.use_forced_check = true
	hurtbox.set_source_and_damage(self, enemy_data.damage)
	starting_position = global_position

#region State machine
func can_go_to_state(new_state: State) -> bool:
	return true

func switch_state(new_state: State, bypass_check: bool):
	if not bypass_check:
		if not can_go_to_state(new_state):
			return

	super.switch_state(new_state, bypass_check)

	handle_new_state()

# Handles when first switching states
func handle_new_state():
	match current_state:
		State.IDLE:
			idle_time()
		State.PATROLLING:
			find_patrol_point()
		State.ATTACKING:
			enter_attack()


# Handles update process for current state
func handle_current_state():
	match current_state:
		State.CHASING: return
		State.ATTACKING: return
		State.DEAD: return

# Handles physics process for current state
func handle_current_state_physics(delta: float):
	match current_state:
		State.PATROLLING:
			patrol(delta)
		State.CHASING:
			chase(delta)



func player_check():
	sees_player = player_check_ray.is_colliding()

	if sees_player:
		player_position = player_check_ray.get_collider().global_position
		direction = 1 if player_position.x > global_position.x else -1
		has_player_position = true


		if current_state != State.CHASING and current_state != State.ATTACKING:
			switch_state(State.CHASING, false)	
	else:
		has_player_position = false

		if current_state ==State.CHASING:
			switch_state(State.IDLE, false)

func idle_time():
	velocity = Vector2.ZERO
	await get_tree().create_timer(randf_range(min_idle, max_idle)).timeout

	switch_state(State.PATROLLING, false)

func find_patrol_point():
	var global_x = starting_position.x + randi_range(-patrol_range, patrol_range)
	destination_position = Vector2(global_x, starting_position.y)
	direction = 1 if destination_position.x > global_position.x else -1

	has_destination = true

func patrol(delta: float):
	if not has_destination:
		find_patrol_point()
		return
	
	velocity.x = direction * patrol_walk_speed

	if abs(global_position.x - destination_position.x) < 5:
		has_destination = false
		switch_state(State.IDLE, false)

func chase(delta: float):
	if not has_player_position:
		switch_state(State.IDLE, false)
		return

	velocity.x = direction * chase_speed

	if abs(global_position.x - player_position.x) < attack_range:
		attack()

func attack():
	switch_state(State.ATTACKING, false)

func enter_attack():
	velocity = Vector2.ZERO

	hurtbox.scale.x = -direction
	await get_tree().create_timer(attack_time).timeout

	if has_player_position:
		if abs(global_position.x - player_position.x) < attack_range:
			attack()
		else:
			switch_state(State.CHASING, false)
	else:
		switch_state(State.IDLE, false)
#endregion
