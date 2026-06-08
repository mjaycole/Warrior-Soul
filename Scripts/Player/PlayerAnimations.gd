# Handles the player animations

extends AnimationPlayer

var player_state
var character_controller
@onready var player_sprite = $"../Sprite2D"
var idle_timer:float = 0

func _ready():
	character_controller = get_parent()
	character_controller.player_state_changed.connect(handle_state_change)

func _process(delta: float):
	idle_time(delta)

func handle_state_change(new_state: player_controller.State):
	player_state = new_state

func idle_time(delta: float):
	if player_state == player_controller.State.IDLE:
		idle_timer += delta
		
		if idle_timer >= get_meta("RestTime"):
			speed_scale = 1
				
			if current_animation != "rest" && current_animation == "idle":
				play("rest")

#Handles the animations for the current state
func handle_animations(last_direction: float):
	handle_direction(last_direction)
	
	match player_state:
		player_controller.State.IDLE:	 handle_idle()
		player_controller.State.WALKING: handle_walk()
		player_controller.State.SPRINTING: handle_sprint()
		player_controller.State.JUMPING: handle_jump()
		player_controller.State.FALLING: handle_fall()
		player_controller.State.DASHING: handle_dash()
		player_controller.State.PUSHING: handle_push()
		player_controller.State.CLIMBING: handle_climb()
		player_controller.State.HURT: handle_hurt()

func handle_direction(last_direction: float):
	if last_direction < 0:
		player_sprite.flip_h = false
	elif last_direction > 0:
		player_sprite.flip_h = true

func handle_idle():
	speed_scale = 1
	if current_animation != "idle" && current_animation != "rest":
		play("idle")
		
		idle_timer = 0

func handle_walk():
	speed_scale = 1.5
	if current_animation != "walk":
		play("walk")

func handle_sprint():
	speed_scale = 1.85
	if current_animation != "walk":
		play("walk")

func handle_jump():
	speed_scale = 1
	if current_animation != "jump":
		play("jump")

func handle_fall():
	speed_scale = 1
	if current_animation != "fall":
		play("fall")

func handle_dash():
	speed_scale = 1
	if current_animation != "dash":
		play("dash")

func handle_push():
	speed_scale = 1
	if current_animation != "push":
		play("push")

func handle_climb():
	speed_scale = 1
	if current_animation != "dash":
		play("dash")

func handle_item_use():
	speed_scale = 1
	var animation
	
	if Core.player_data.inventory.active_items["right_hand"]:
		var weapon = Core.player_data.inventory.active_items["right_hand"] as Weapon
		
		if weapon.weapon_type == Weapon.WeaponType.MELEE:
			animation = "melee_attack"
			

	if current_animation != animation:
		play(animation)
		
func handle_hurt():
	speed_scale = 1
	if current_animation != "hurt":
		play("hurt")
		
		
		
