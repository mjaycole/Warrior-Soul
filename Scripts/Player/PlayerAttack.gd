#Handles the player attacking - moving damage dealer, launching projectile, etc

extends Node

signal attack_finished



func handle_attack(weapon: Weapon, player_global_position: Vector2, mouse_pos: Vector2):
	#Instantiate the damage dealing node
	var damage_dealer: Hurtbox = weapon.damage_dealer_node.instantiate() 
	add_child(damage_dealer)

	#Initialize
	damage_dealer.set_source_and_damage(get_parent(), weapon.damage)
	damage_dealer.initialize(player_global_position, mouse_pos)


	await get_tree().create_timer(weapon.use_time).timeout

	attack_finished.emit()
