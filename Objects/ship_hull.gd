class_name ShipHull extends ShipComponent

@export var max_hp: float = 0.0
@export var damage_threshold: float = 0.0


func _get_stat_string() -> String:
	return """Max HP: {max_hp}
	Min Damage: {damage_threshold}
	""" + super()
