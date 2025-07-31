class_name ShipThruster extends ShipComponent

@export var thrust: float = 0.0


func _get_stat_string() -> String:
	return """Thrust: {thrust} kN
	""" + super()
