extends Node2D

@onready var damageable = $"Damageable"

func _ready() -> void:
	damageable.damage_taken.connect(on_take_damage)
	damageable.died.connect(on_die)


func on_take_damage(source: Node, amount: float):
	print("Took damage from: ", source.name, " for ", amount, " damage")

func on_die():
	queue_free()
