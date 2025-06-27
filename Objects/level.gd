class_name Level extends GravityController

const BODIES: int = 1000
const DISTRIBUTION_RADIUS: float = 1000
const MASS_MIDPOINT: float = 1e5
const IV_MIDPOINT: float = 1.0
const RADIUS_MIDPOINT: float = 10

var bodies: int
var distribution_radius: float
var mass_midpoint: float
var iv_midpoint: float
var radius_midpoint: float

enum m {SPARSE, THICK, DENSE, GASEOUS, ROCKY}
var mods: Array[m] = []


func _ready() -> void:
	do_collision = true
	
	var count: int
	var r: float = randf()
	if r <= 1.0/2:
		count = 0
	elif r <= 5.0/6:
		count = 1
	elif r <= 17.0/18:
		count = 2
	else:
		count = 3
	
	for i in count:
		mods.append([m.SPARSE, m.THICK, m.DENSE, m.GASEOUS, m.ROCKY].pick_random())


func distribute_bodies() -> void:
	bodies = BODIES
	distribution_radius = DISTRIBUTION_RADIUS
	
	mass_midpoint = MASS_MIDPOINT
	iv_midpoint = IV_MIDPOINT
	
	radius_midpoint = RADIUS_MIDPOINT
	
	
	for i in bodies:
		var mass: float = mass_coefficient() * mass_midpoint
		var radius: float = radius_coefficient() * radius_midpoint
		
		var angle: float = randf_range(0, TAU)
		var distance: float = sqrt(randf()) * distribution_radius
		var position_x: float = cos(angle) * distance
		var position_y: float = sin(angle) * distance
		
		add_body(mass, radius, position_x, position_y, 0)


func mass_coefficient() -> float:
	return 10 ** (2 - (randf() + randf()) ** 0.4)


func radius_coefficient() -> float:
	return 0.75 + ((randf() + randf()) ** 1.7) / 2.0
