

class_name Hurtbox
extends Area2D

signal dealt_damage(receiving_object)

@export var animation_player: AnimationPlayer
@export var live_duration: float = 1.0

var source: Node
var damage: float = 10
var use_forced_check: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if use_forced_check:
		return
	
	if area is Damageable:
		area.take_damage(source, damage)
		dealt_damage.emit(area)

func _force_damageCheck():
	var overlapping = get_overlapping_areas()
	for area in overlapping:
		if area is Damageable:
			area.take_damage(source, damage)
			dealt_damage.emit(area)

func set_source_and_damage(_source: Node, _damage: float):
	source = _source
	damage = _damage

func initialize(owner_global_position: Vector2, mouse_pos: Vector2):
	var direction = (mouse_pos - owner_global_position).normalized()
	rotation = direction.angle()

	if animation_player:
		animation_player.play("init")

	await get_tree().create_timer(live_duration).timeout

	if is_instance_valid(self):
		queue_free()
