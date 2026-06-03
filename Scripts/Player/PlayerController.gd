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
enum State { IDLE, WALKING, SPRINTING, PUSHING, JUMPING, FALLING, DASHING, GRABBING_LEDGE, CLIMBING, USING_ITEM, DEAD }
var current_state = State.IDLE


#Godot Functions
func _ready():
	print("Player Inventory Exists: ", Core.player_data.inventory.has_item_name("Broken Sword"))
	
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


#State Changing
func switch_state(new_state: State):
	current_state = new_state
	player_state_changed.emit(current_state)

func reset_state():
	if velocity.x != 0:
		switch_state(State.WALKING)
	else: 
		switch_state(State.IDLE)

func can_process_movement() -> bool:
	return current_state != State.USING_ITEM && current_state != State.DEAD

#Movement Listeners
func handle_walk_input(is_sprinting: bool):
	if not can_process_movement():
		return
		
	if is_sprinting:
		switch_state(State.SPRINTING)
	else:
		switch_state(State.WALKING)

func handle_idle_input():
	if not can_process_movement():
		return
		
	switch_state(State.IDLE)
	
func handle_jump_input(jumping: bool):
	if not can_process_movement():
		return
		
	if jumping:
		switch_state(State.JUMPING)
	else:
		switch_state(State.FALLING)

func handle_jump_finish():
	if not can_process_movement():
		return
		
	reset_state()

func handle_dash_input():
	if not can_process_movement():
		return
		
	switch_state(State.DASHING)

func handle_dash_finish():
	if not can_process_movement():
		return
		
	reset_state()

func handle_push(pushing: bool):
	if not can_process_movement():
		return
		
	if pushing:
		switch_state(State.PUSHING)
	else:
		reset_state()

func handle_ledge_grab(on_ledge: bool):
	if not can_process_movement():
		return
		
	if on_ledge:
		switch_state(State.GRABBING_LEDGE)

func handle_climb():
	if not can_process_movement():
		return
		
	switch_state(State.CLIMBING)

func handle_climb_finished():
	if not can_process_movement():
		return
		
	reset_state()

#Item Usage Listeners
func handle_item_use(item_compass: String):
	if current_state == State.DEAD:
		return

	var item: Item = Core.player_data.inventory.active_items[item_compass]

	if item == null:
		return

	if current_state == State.DASHING or current_state == State.USING_ITEM or current_state == State.GRABBING_LEDGE or current_state == State.CLIMBING:
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
