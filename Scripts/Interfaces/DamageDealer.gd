

class_name DamageDealer
extends Area2D

@export var source: Node
@export var damage: float = 10

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Damageable:
		area.take_damage(source, damage)

func initialize(owner_global_position: Vector2, mouse_pos: Vector2):
	var direction = (mouse_pos - owner_global_position).normalized()
	rotation = direction.angle()

func activate():
	monitoring = true;

func deactivate():
	monitoring = false
