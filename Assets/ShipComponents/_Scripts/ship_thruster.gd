class_name ShipThruster extends ShipComponent

@export var thrust: float = 0.0
@export var visual_profile: ThrustParticleProfile


func _get_stat_string() -> String:
	return """Thrust: {thrust} kN
	""" + super()
