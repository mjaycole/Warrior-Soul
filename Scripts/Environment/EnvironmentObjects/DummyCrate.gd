

extends CharacterBody2D

@onready var damageable = $"Damageable"
@onready var anim: AnimationPlayer = $"AnimationPlayer"
@onready var pushable: Pushable = $"Pushable"

@export var weight_override: float = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	anim.play("box_idle")
	anim.animation_finished.connect(on_anim_complete)
	damageable.damage_taken.connect(on_take_damage)
	damageable.died.connect(on_die)
	pushable.pushed_started.connect(on_pushed)
	pushable.weight = weight_override

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func on_anim_complete(anim_name: String):
	damageable.command_unfreeze()
	anim.play("box_idle")

func on_take_damage(source: Node, amount: float):
	print("Took damage from: ", source.name, " for ", amount, " damage")
	damageable.command_freeze()
	anim.play("box_hit")

func on_die():
	return
	# queue_free()

func on_pushed(direction: Vector2, force: float, weight: float):
	velocity.x = direction.x * force * weight
