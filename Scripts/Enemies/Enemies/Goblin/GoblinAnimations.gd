

extends EnemyAnimations

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
@export var death_hframes: int
@export var death_vframes: int



func handle_state_switch_animations():
	match current_state:
		Enemy.State.IDLE: handle_idle()
		Enemy.State.PATROLLING: handle_walk()
		Enemy.State.CHASING: handle_chase()
		Enemy.State.ATTACKING: handle_attack()
		Enemy.State.DEAD: handle_death()


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
		stop()

		if death_frames && sprite:
			sprite.texture = death_frames
			sprite.hframes = death_hframes
			sprite.vframes = death_vframes

		play("death")