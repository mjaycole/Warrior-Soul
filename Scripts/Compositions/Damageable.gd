#Handles collision with things that deal damage to it

extends Area2D
class_name Damageable

signal damage_taken(source: Node, amount: float)
signal hit_while_frozen(source: Node, amount: float)
signal died

@export var health: float = 10

var frozen: bool = false

func command_freeze():
	frozen = true

func command_unfreeze():
	frozen = false

func take_damage(source: Node, amount: float):
	if frozen:
		hit_while_frozen.emit(source, amount)
		return

	health -= amount
	damage_taken.emit(source, amount)
	if health <= 0:
		died.emit()
