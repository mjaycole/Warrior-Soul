# Handles the state machine for Goblin grunt

extends Enemy




func _ready():
	super._ready()

func _physics_process(delta: float):
	if current_state != State.DEAD:
		super._physics_process(delta)

func can_go_to_state(new_state: State) -> bool:
	return true

func switch_state(new_state: State, bypass_check: bool):
	super.switch_state(new_state, bypass_check)

func on_die():
	super.on_die()
