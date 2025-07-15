class_name Ship extends Resource

var components: Array[ShipComponent] = []

var trigger_components: Array[ShipComponent] = []

# Warnings
var no_hull: bool
var has_multiple_hulls: bool
var no_thruster: bool
var has_multiple_thrusters: bool
var too_many_triggers: bool
# Stats
var thrust: float = 0
var mass: float = 0
var max_hp: float = 0
var damage_threshold: float = 0

# ? other stuff i guess idk
var acceleration: float = 0
var hp: float = 0


func set_components(_components: Array[ShipComponent] = []):
	# Set
	if _components:
		components = _components
	# Reset
	thrust = 0
	mass = 0
	no_hull = true
	no_thruster = true
	has_multiple_hulls = false
	has_multiple_thrusters = false
	too_many_triggers = false
	# Iterate
	for cmpnt in components:
		mass += cmpnt.mass
		if cmpnt is ShipThruster:
			if !no_thruster:
				has_multiple_thrusters = true
			no_thruster = false
			thrust = max(thrust, cmpnt.thrust)
		elif cmpnt is ShipHull:
			if !no_hull:
				has_multiple_hulls = true
			no_hull = false
			max_hp = max(cmpnt.max_hp, max_hp)
			damage_threshold = max(cmpnt.damage_threshold, damage_threshold)
		elif cmpnt is TriggerComponent:
			if len(trigger_components) == 4:
				too_many_triggers = true
			else:
				trigger_components.append(cmpnt)
	acceleration = thrust / mass
	hp = max_hp
