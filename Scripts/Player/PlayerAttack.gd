#Handles the player attacking - moving damage dealer, launching projectile, etc

extends Node

signal attack_finished



func handle_attack(weapon: Weapon, player_global_position: Vector2, mouse_pos: Vector2):
	#Instantiate the damage dealing node
	var damage_dealer: DamageDealer = weapon.damage_dealer_node.instantiate()
	damage_dealer.source = get_parent()
	damage_dealer.damage = weapon.damage

	#Add to parent
	add_child(damage_dealer)

	#Set rotation
	damage_dealer.initialize(player_global_position, mouse_pos)
	damage_dealer.activate()

	await get_tree().create_timer(weapon.use_time).timeout

	#Deactivate
	if is_instance_valid(damage_dealer):
		damage_dealer.deactivate()
		damage_dealer.queue_free()

	attack_finished.emit()
