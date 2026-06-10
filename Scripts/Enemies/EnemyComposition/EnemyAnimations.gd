# Handles the animations for the enemy

extends AnimationPlayer
class_name EnemyAnimations


@export var sprite: Sprite2D
@export var idle_frames: Texture2D
@export var walk_frames: Texture2D
@export var attack_frames: Texture2D
@export var death_frames: Texture2D

var enemy_controller: Enemy
var current_state: Enemy.State

func _ready():
	enemy_controller = get_parent()
	enemy_controller.enemy_state_changed.connect(handle_state_change)

func handle_state_change(new_state: Enemy.State):
	current_state = new_state

	handle_state_switch_animations()

func handle_state_switch_animations():
	match current_state:
		Enemy.State.IDLE: handle_idle()
		Enemy.State.CHASING, Enemy.State.PATROLLING: handle_walk()
		Enemy.State.ATTACKING: handle_attack()
		Enemy.State.DEAD: handle_death()

func handle_state_animations(delta: float):
	return

func handle_idle():
	speed_scale = 1
	if current_animation != "idle":
		if idle_frames && sprite:
			sprite.texture = idle_frames
			
		play("idle")

func handle_walk():
	speed_scale = 1
	if current_animation != "walk":
		if walk_frames && sprite:
			sprite.texture = walk_frames

		play("walk")

func handle_attack():
	speed_scale = 1
	if current_animation != "attack":
		if attack_frames && sprite:
			sprite.texture = attack_frames

		play("attack")

func handle_death():
	speed_scale = 1
	if current_animation != "death":
		if death_frames && sprite:
			sprite.texture = death_frames

		play("death")