# Dummy object to hit AND take damage from

extends EnvironmentNode

@onready var damageable = $"Damageable"
@onready var anim: AnimationPlayer = $"AnimationPlayer"
@onready var damage_text: Label = $"Label"
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var dealing_damage_sprite: Sprite2D = $Sprite2D/ColorModulate

@export var weight_override: float = 1
@export var damage_amount: float = 10
@export var time_between_hurt: float = 2
@export var damage_dealing_enabled: bool = true

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void: 
	anim.play("idle")
	anim.animation_finished.connect(on_anim_complete)

	damageable.damage_taken.connect(on_take_damage)
	damageable.died.connect(on_die)

	hurtbox.use_forced_check = true
	hurtbox.set_source_and_damage(self, damage_amount)
	hurtbox.dealt_damage.connect(on_deal_damage)
	damage_dealing()


func on_anim_complete(anim_name: String):
	damageable.command_unfreeze()
	anim.play("idle")

# Taking damage
func on_take_damage(source: Node, amount: float):
	print("Took damage from: ", source.name, " for ", amount, " damage")
	damageable.command_freeze()
	damage_text.text = "-" + str(int(amount))
	anim.play("hit")

func on_die():
	return
	# queue_free()


# Giving damage

func damage_dealing():
	if not damage_dealing_enabled:
		return
	
	print("Dealing damage")
	dealing_damage_sprite.visible = true
	hurtbox.visible = true
	hurtbox._force_damageCheck()

	await get_tree().create_timer(.1).timeout

	dealing_damage_sprite.visible = false
	hurtbox.visible = false
	print("Waiting for reset")

	await  get_tree().create_timer(time_between_hurt).timeout

	damage_dealing()




func on_deal_damage(area: Area2D):
	hurtbox.visible = false