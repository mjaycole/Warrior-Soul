# Dummy object to hit

extends Node2D

@onready var damageable = $"Damageable"
@onready var anim: AnimationPlayer = $"AnimationPlayer"
@onready var damage_text: Label = $"Label"

@export var weight_override: float = 1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void: 
	anim.play("idle")
	anim.animation_finished.connect(on_anim_complete)
	damageable.damage_taken.connect(on_take_damage)
	damageable.died.connect(on_die)

func on_anim_complete(anim_name: String):
	damageable.command_unfreeze()
	anim.play("idle")

func on_take_damage(source: Node, amount: float):
	print("Took damage from: ", source.name, " for ", amount, " damage")
	damageable.command_freeze()
	damage_text.text = "-" + str(int(amount))
	anim.play("hit")

func on_die():
	return
	# queue_free()
