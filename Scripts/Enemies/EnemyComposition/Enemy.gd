# This is the parent class node for all enemy state machine handles

extends CharacterBody2D
class_name Enemy

# Signals
signal enemy_state_changed(new_state: State)
signal enemy_damaged(amount: float)
signal enemy_dead


enum State { IDLE, PATROLLING, CHASING, ATTACKING, DEAD}
var current_state: State = State.IDLE

# Required fields
@export var enemy_id: String = "" # leave empty except for enemies placed inside a scene
@export var damageable: Damageable
@export var animations: EnemyAnimations
@export var audio_controller: EnemyAudio
@export var navigatiion: NavigationAgent2D

# Variables
var enemy_data: EnemyData
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var initialized: bool = false
var frozen: bool = false

# Godot functions
func _ready():
	pass

	# if existing_enemy_id != "":
	# 	var data = EnemyFetcher.get_enemy(existing_enemy_id)
	# 	if data:
	# 		initialize(data)

func _process(delta: float):
	pass

func _physics_process(delta: float):	
	if frozen or current_state == State.DEAD:
		return
	
	animations.handle_state_animations(delta)

	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()

# State machine
func initialize():
	if initialized:
		return
	
	initialized = true

	enemy_data = EnemyFetcher.get_enemy(enemy_id)

	damageable.damage_taken.connect(on_take_damage)
	damageable.died.connect(on_die)
	damageable.health = enemy_data.max_health

	if not audio_controller:
		audio_controller = $"EnemyAudio"
	audio_controller.initialize(enemy_data)

	switch_state(State.IDLE, true)

func switch_state(new_state: State, bypass_check: bool):
	if current_state == State.DEAD:
		return
	
	current_state = new_state
	enemy_state_changed.emit(current_state)
	

# Event listeners
func on_take_damage(source: Node, amount: float):
	enemy_damaged.emit(amount)

func on_die():
	switch_state(State.DEAD, true)

	damageable.queue_free()
	$CollisionShape2D.set_deferred("disabled", true)

	enemy_dead.emit()
