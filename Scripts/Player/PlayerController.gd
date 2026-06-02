#The core of the player controller

extends CharacterBody2D
class_name player_controller

#Signals
signal player_state_changed(new_state)
signal player_use_item(item_compass)

#Sub-Node References
@onready var player_animations = $AnimationPlayer
@onready var player_physics = $Physics
@onready var player_item_use = $"PlayerItemUsage"

#State Machine
enum State { IDLE, WALKING, SPRINTING, PUSHING, JUMPING, FALLING, DASHING, GRABBING_LEDGE, CLIMBING, ATTACKING, DEAD }
var current_state = State.IDLE


#Godot Functions
func _ready():
	print("Player Inventory Exists: ", Core.player_data.inventory.has_item_name("Broken Sword"))
	
	Core.player_data.inventory.set_right_hand(Core.player_data.inventory.items[0])
	
	player_state_changed.emit(current_state)
	player_physics.walk_input.connect(handle_walk_input)
	player_physics.idle_input.connect(handle_idle_input)
	player_physics.jump_input.connect(handle_jump_input)
	player_physics.jump_finish.connect(handle_jump_finish)
	player_physics.dash_input.connect(handle_dash_input)
	player_physics.dash_finish.connect(handle_dash_finish)
	player_physics.push_input.connect(handle_push)
	player_physics.ledge_grabbed.connect(handle_ledge_grab)
	player_physics.climbing_input.connect(handle_climb)
	player_physics.climbing_finished.connect(handle_climb_finished)
	
	player_item_use.item_use.connect(handle_item_use)

func _physics_process(delta: float):
	player_animations.handle_animations()
	player_physics.calculated_physics(delta)


#State Changing
func switch_state(new_state: State):
	current_state = new_state
	player_state_changed.emit(current_state)

func reset_state():
	if velocity.x != 0:
		switch_state(State.WALKING)
	else: 
		switch_state(State.IDLE)


#Movement Listeners
func handle_walk_input(is_sprinting: bool):
	if current_state == State.ATTACKING:
		return
		
	if is_sprinting:
		switch_state(State.SPRINTING)
	else:
		switch_state(State.WALKING)

func handle_idle_input():
	if current_state == State.ATTACKING:
		return
		
	switch_state(State.IDLE)
	
func handle_jump_input(jumping: bool):
	if current_state == State.ATTACKING:
		return
		
	if jumping:
		switch_state(State.JUMPING)
	else:
		switch_state(State.FALLING)

func handle_jump_finish():
	if current_state == State.ATTACKING:
		return
		
	reset_state()

func handle_dash_input():
	if current_state == State.ATTACKING:
		return
		
	switch_state(State.DASHING)

func handle_dash_finish():
	if current_state == State.ATTACKING:
		return
		
	reset_state()

func handle_push(pushing: bool):
	if current_state == State.ATTACKING:
		return
		
	if pushing:
		switch_state(State.PUSHING)
	else:
		reset_state()

func handle_ledge_grab(on_ledge: bool):
	if current_state == State.ATTACKING:
		return
		
	if on_ledge:
		switch_state(State.GRABBING_LEDGE)

func handle_climb():
	if current_state == State.ATTACKING:
		return
		
	switch_state(State.CLIMBING)

func handle_climb_finished():
	if current_state == State.ATTACKING:
		return
		
	reset_state()

#Item Usage Listeners
func handle_item_use(item_compass: String):
	match item_compass:
		"right_hand": handle_right_hand_item()
			
func handle_right_hand_item():
	if current_state == State.DEAD:
		return
	
	if Core.player_data.inventory.right_hand == null:
		return
		
	if current_state == State.DASHING or current_state == State.ATTACKING or current_state == State.GRABBING_LEDGE or current_state == State.CLIMBING:
		return

	var weapon = Core.player_data.inventory.right_hand as Weapon

	switch_state(State.ATTACKING)

	player_use_item.emit(weapon.id)
	player_animations.handle_right_hand_attack()
	
	await get_tree().create_timer(weapon.attack_time).timeout
	
	reset_state()
