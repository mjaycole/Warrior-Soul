

class_name Hurtbox
extends Area2D

@export var live_duration: float = 1.0

var source: Node
var damage: float = 10

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Damageable:
		area.take_damage(source, damage)

func set_source_and_damage(_source: Node, _damage: float):
	source = _source
	damage = _damage

func initialize(owner_global_position: Vector2, mouse_pos: Vector2):
	var direction = (mouse_pos - owner_global_position).normalized()
	rotation = direction.angle()

	await get_tree().create_timer(live_duration).timeout

	if is_instance_valid(self):
		queue_free()
