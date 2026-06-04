#Item behavior for the generic sword

extends ItemBehavior


var damage_dealer: Hurtbox

func use(player: player_controller):
	#Instantiate the damage dealing node
	var weapon = item_data as Weapon
	damage_dealer = weapon.damage_dealer_node.instantiate() 
	add_child(damage_dealer)

	#Initialize
	damage_dealer.set_source_and_damage(player, weapon.damage)
	damage_dealer.initialize(player.global_position, player.get_global_mouse_position())

	timer_node.wait_time = item_data.use_time
	timer_node.start()
	
func use_completed():
	if damage_dealer:
		damage_dealer.queue_free()
		damage_dealer = null
	
	item_use_completed.emit() 
