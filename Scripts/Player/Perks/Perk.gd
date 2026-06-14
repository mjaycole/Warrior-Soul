# This handles storing data about a perk, including the effect_target and how much it affects it per rank

extends Resource
class_name Perk

@export var id: String
@export var perk_name: String
@export var description: String
@export var max_ranks: int = 5
@export var current_rank: int = 0
@export var required_stat_level: int = 1

# Which stat this perk belongs to
@export var stat: String

# The actual numerical effect - what it modifies and by how much per rank
@export var effect_target: StringName  # e.g. &"melee_damage", &"dash_distance"
@export var effect_per_rank: float


func get_current_effect() -> float:
    return effect_per_rank * current_rank

func upgrade():
    if current_rank < max_ranks:
        current_rank += 1