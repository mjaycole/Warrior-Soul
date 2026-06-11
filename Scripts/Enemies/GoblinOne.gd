# Handles the state machine for Goblin grunt

extends Enemy


# Patrolling and idle
@export var min_idle: float = 3
@export var max_idle: float = 3
@export var patrol_range: float
@export var patrol_walk_speed: float

# Player detection
@onready var player_check_ray: RayCast2D = $Resources/PlayerDetect
@export var omniscent: bool = false #Can see in front AND behind them

var starting_position
var destination_position: Vector2
var direction: float = -1
var sees_player: bool = false

# Godot functions
func _ready():
	super._ready()

func _process(delta: float):
	handle_current_state()

	player_check_ray.scale.x = direction

	super._physics_process(delta)

func _physics_process(delta: float):
	super._physics_process(delta)

	handle_current_state_physics(delta)

	animations.handle_direction(direction)

func initialize():
	super.initialize()
	
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



func player_check():
	sees_player = player_check_ray.is_colliding()

func idle_time():
	velocity = Vector2.ZERO
	await get_tree().create_timer(randf_range(min_idle, max_idle)).timeout

	switch_state(State.PATROLLING, false)

func find_patrol_point():
	var global_x = starting_position.x + randi_range(-patrol_range, patrol_range)
	destination_position = Vector2(global_x, starting_position.y)
	direction = 1 if destination_position.x > global_position.x else -1

func patrol(delta: float):
	if not destination_position:
		find_patrol_point()
		return
	
	velocity.x = direction * patrol_walk_speed

	if abs(global_position.x - destination_position.x) < 5:
		switch_state(State.IDLE, false)
#endregion

# Event listeners
func on_take_damage(source: Node, amount: float):
	super.on_take_damage(source, amount)

func on_die():
	super.on_die()
