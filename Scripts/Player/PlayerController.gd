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
@onready var player_attack = $"PlayerAttack"

#State Machine
enum State { 
	IDLE, WALKING, SPRINTING, PUSHING, JUMPING, FALLING, 
	DASHING, GRABBING_LEDGE, CLIMBING, USING_ITEM, DEAD }

var current_state = State.IDLE


#region Godot Functions
#Godot Functions
func _ready():
	#TODO - Move this over to game initialization logic	
	Core.player_data.inventory.set_active_item("right_hand", Core.player_data.inventory.items[0])
	
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

	player_attack.attack_finished.connect(handle_attack_finished)

func _physics_process(delta: float):
	player_animations.handle_animations()
	player_physics.calculated_physics(delta)

#endregion

#region State Changing
#State Changing
func switch_state(new_state: State):
	if not can_go_to_state(new_state):
		return

	current_state = new_state
	player_state_changed.emit(current_state)

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
				State.CLIMBING
			]

		State.DASHING: 
			return current_state not in [
				State.USING_ITEM,
				State.DASHING,
				State.GRABBING_LEDGE,
				State.CLIMBING
			]

		State.GRABBING_LEDGE:
			return current_state not in [
				State.USING_ITEM,
				State.GRABBING_LEDGE,
				State.CLIMBING
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
				State.CLIMBING
			]

		State.DEAD: 
			return true
	
	# Any unhandled state is blocked - add new states explicitly above
	return false

func reset_state():
	# Override can_go_to_state by setting directly since we're resetting
	if is_on_floor():
		if velocity.x != 0:
			if player_physics.sprinting:
				current_state = State.SPRINTING
			else:
				current_state = State.WALKING
		else: 
			switch_state(State.IDLE)
	else:
		if velocity.y < 0:
			current_state = State.JUMPING
		else:
			current_state = State.FALLING

	player_state_changed.emit(current_state)


#endregion

#region Movement Listeners
#Movement Listeners
func handle_walk_input(is_sprinting: bool):
	if is_sprinting:
		switch_state(State.SPRINTING)
	else:
		switch_state(State.WALKING)

func handle_idle_input():
	switch_state(State.IDLE)
	
func handle_jump_input(jumping: bool):
	if jumping:
		switch_state(State.JUMPING)
	else:
		switch_state(State.FALLING)

func handle_jump_finish():
	reset_state()

func handle_dash_input():
	switch_state(State.DASHING)

func handle_dash_finish():
	reset_state()

func handle_push(pushing: bool):
	if pushing:
		switch_state(State.PUSHING)
	else:
		reset_state()

func handle_ledge_grab(on_ledge: bool):
	if on_ledge:
		switch_state(State.GRABBING_LEDGE)

func handle_climb():
	switch_state(State.CLIMBING)

func handle_climb_finished():
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

	match item.item_type:
		Item.ItemType.WEAPON: handle_attack(item as Weapon)

func handle_attack(weapon: Weapon):
	var mouse_pos = get_global_mouse_position()

	player_use_item.emit(weapon.id)
	player_animations.handle_item_use()
	player_attack.handle_attack(weapon, global_position, mouse_pos)
	
	switch_state(State.USING_ITEM)
	
func handle_attack_finished():
	reset_state()

#endregion
