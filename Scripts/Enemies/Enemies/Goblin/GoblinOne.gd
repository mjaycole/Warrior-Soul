# Handles the state machine for Goblin grunt

extends Enemy


# Patrolling and idle
@export_group("Patrolling and Idle")
@export var min_idle: float = 3
@export var max_idle: float = 3
@export var patrol_range: float
@export var patrol_walk_speed: float

# Player detection
@export_group("Player Check")
@onready var player_check_ray: RayCast2D = $Resources/PlayerDetect
@onready var player_aware: Area2D = $Resources/PlayerAware
@onready var hurtbox: Hurtbox = $Hurtbox
@export var omniscent: bool = false #Can see in front AND behind them

# Attacking
@export_group("Chase and Attack")
@export var chase_speed: float
@export var attack_range: float = 2
@export var attack_time: float = 1.5

@onready var wall_check: RayCast2D = $Resources/WallCheck
@onready var edge_check: RayCast2D = $Resources/EdgeCheck

var starting_position
var destination_position: Vector2
var has_destination: bool = false
var direction: float = -1
var sees_player: bool = false
var player_in_range: bool = false
var player: Node
var player_position: Vector2
var has_player_position: bool = false
var detects_wall: bool = false
var detects_edge: bool = false

# Godot functions
func _ready():
	super._ready()
	player_aware.body_entered.connect(_on_player_enter_range)
	player_aware.body_exited.connect(_on_player_leave_range)

func _process(delta: float):
	if frozen or current_state == State.DEAD:
		return

	handle_current_state()

	resources.scale.x = -direction

	wall_and_edge_check()
	player_check()
	

func _physics_process(delta: float):
	super._physics_process(delta)

	animations.handle_direction(direction)

func initialize():
	super.initialize()

	hurtbox.use_forced_check = true
	hurtbox.set_source_and_damage(self, enemy_data.damage)
	starting_position = global_position

#region State machine
func can_go_to_state(new_state: State) -> bool:
	match new_state:
		State.IDLE: 
			# If we've just been chasing or attacking the player, keep chasing if the player is still in range
			if current_state == State.CHASING or current_state == State.ATTACKING:
				return not player_in_range and not detects_edge and not detects_wall
		State.PATROLLING: return true
		State.CHASING:
			if detects_edge or detects_wall:
				return false
		State.ATTACKING: return true
		State.DEAD: return true

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
		State.PATROLLING: patrol()
		State.CHASING: chase()
		State.ATTACKING: return
		State.DEAD: return

func wall_and_edge_check():
	detects_wall = wall_check.is_colliding()
	detects_edge = !edge_check.is_colliding()

func _on_player_enter_range(body: Node):
	if body is player_controller:
		player = body
		player_in_range = true
		player_position = body.global_position
		print("Player entered")

func _on_player_leave_range(body: Node):
	if body is player_controller:
		player_in_range = false
		print("Player left")

func player_check() -> void:
	sees_player = player_check_ray.is_colliding()

	if sees_player:
		# Update player position regardless of state
		player_position = player_check_ray.get_collider().global_position
		has_player_position = true
		
		if current_state != State.CHASING and current_state != State.ATTACKING:
			if can_go_to_state(State.CHASING):
				switch_state(State.CHASING, false)
	elif omniscent and player_in_range:
		if not detects_edge and not detects_wall:  # add this check
			player_position = player.global_position
			has_player_position = true
			if current_state != State.CHASING and current_state != State.ATTACKING:
				switch_state(State.CHASING, false)
	else:
		has_player_position = false
		if current_state == State.CHASING:
			switch_state(State.IDLE, false)

func idle_time():
	omniscent = false
	enemy_physics.command_freeze()

	await get_tree().create_timer(randf_range(min_idle, max_idle)).timeout

	enemy_physics.command_unfreeze()

	switch_state(State.PATROLLING, false)

func find_patrol_point():
	var global_x = starting_position.x + randi_range(-patrol_range, patrol_range)
	destination_position = Vector2(global_x, starting_position.y)
	direction = 1 if destination_position.x > global_position.x else -1

	has_destination = true

func patrol():
	if not has_destination:
		find_patrol_point()
		return
	
	if abs(global_position.x - destination_position.x) < 5 or detects_edge or detects_wall:
		has_destination = false
		switch_state(State.IDLE, false)

func chase():
	if not has_player_position:
		switch_state(State.IDLE, false)
		return
	
	if detects_edge or detects_wall:
		enemy_physics.command_freeze()
		switch_state(Enemy.State.IDLE, false)
		return

	enemy_physics.command_unfreeze()
	direction = 1 if player_position.x > global_position.x else -1
	omniscent = true

	if abs(global_position.x - player_position.x) < attack_range:
		attack()

func attack():
	switch_state(State.ATTACKING, false)

func enter_attack():
	enemy_physics.command_freeze()
	hurtbox.scale.x = -direction
	
	await get_tree().create_timer(attack_time).timeout
	
	enemy_physics.command_unfreeze()

	if not has_player_position:
		switch_state(State.IDLE, false)
		return

	if abs(global_position.x - player_position.x) < attack_range:
		switch_state(State.CHASING, false)  # chase briefly then attack again naturally
	else:
		switch_state(State.CHASING, false)
#endregion


func on_die():
	super.on_die()

	hurtbox.queue_free()
