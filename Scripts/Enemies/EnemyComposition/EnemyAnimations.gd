# Handles the animations for the enemy

extends AnimationPlayer
class_name EnemyAnimations


@export var sprite: Sprite2D
@export var idle_frames: Texture2D
@export var idle_hframes: int
@export var idle_vframes: int
@export var walk_frames: Texture2D
@export var walk_hframes: int
@export var walk_vframes: int
@export var attack_frames: Texture2D
@export var attack_hframes: int
@export var attack_vframes: int
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
		Enemy.State.PATROLLING: handle_walk()
		Enemy.State.CHASING: handle_chase()
		Enemy.State.ATTACKING: handle_attack()
		Enemy.State.DEAD: handle_death()

func handle_state_animations(delta: float):
	return

func handle_direction(direction: float):
	if direction < 0:
		sprite.flip_h = false
	elif direction > 0:
		sprite.flip_h = true

func handle_idle():
	speed_scale = 1
	if current_animation != "idle":
		stop()
		
		if idle_frames && sprite:
			sprite.texture = idle_frames
			sprite.hframes = idle_hframes
			sprite.vframes = idle_vframes
			
		play("idle")

func handle_walk():
	speed_scale = 1
	if current_animation != "walk":
		stop()

		if walk_frames && sprite:
			sprite.texture = walk_frames
			sprite.hframes = walk_hframes
			sprite.vframes = walk_vframes

		play("walk")

func handle_chase():
	speed_scale = 1.5
	if current_animation != "walk":
		stop()

		if walk_frames && sprite:
			sprite.texture = walk_frames
			sprite.hframes = walk_hframes
			sprite.vframes = walk_vframes

		play("walk")

func handle_attack():
	speed_scale = 1
	if current_animation != "attack":
		stop()

		if attack_frames && sprite:
			sprite.texture = attack_frames
			sprite.hframes = attack_hframes
			sprite.vframes = attack_vframes

		play("attack")

func handle_death():
	speed_scale = 1
	if current_animation != "death":
		if death_frames && sprite:
			sprite.texture = death_frames

		play("death")