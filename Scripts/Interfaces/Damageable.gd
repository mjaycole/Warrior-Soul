#Handles collision with things that deal damage to it

extends Area2D
class_name Damageable

signal damage_taken(source: Node, amount: float)
signal died

@export var health: float = 10

func take_damage(source: Node, amount: float):
	health -= amount
	damage_taken.emit(source, amount)
	if health <= 0:
		died.emit()
