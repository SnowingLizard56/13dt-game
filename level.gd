class_name Level extends GravityController

const DENSITIES: PackedFloat64Array = [1.2e7, 4.8e7, 9.6e7, 1.2e8, 4e7, 3.2e7, 2.8e7]
const BIG_G: float = 6.67e-11

var total_mass: float
var clockwise: float


func _init() -> void:
	# Randomly generate some parameters
	total_mass = 11 ** (15 + randf() - randf())
	if randi_range(0, 1) == 0:
		clockwise = TAU / 4
	else:
		clockwise = -TAU / 4


func distribute_bodies() -> void:
	add_bodies(total_mass, Vector2.ZERO, 1500, 0, Vector2.ZERO)


# This function is recursive
func add_bodies(mass: float, centre: Vector2, max_radius: float, depth: int, velocity: Vector2) -> void:
	# Max depth. No moons.
	var moon_mass: float = 0.0
	if depth <= 6 and (depth <= 1 or randf() < 0.91):
		moon_mass = mass * randf_range(0.13, 0.31)
		mass -= moon_mass
	var radius: float
	# Main bodies
	if mass / total_mass >= 0.097 and randf() < 0.03:
		# Binary+
		var mass_ratio: float = randf_range(0.41, 0.61)
		var stars_distance: float = randf_range(0.41, 0.83) * max_radius * 2
		radius = max(mass_ratio, 1-mass_ratio) * stars_distance
		# Gotta do a little maths
		var net_velocity: float = sqrt(mass * BIG_G / stars_distance)
		var angle: float = randf_range(0, TAU)
		
		# Call add_bodies for each new body. Args follow:
		# Proprtion of mass
		# Current centre plus offset
		# Distance from centre -35%
		# Current depth +1
		# Current velocity plus relative
		
		add_bodies(
			mass_ratio * mass,
			centre + Vector2.from_angle(angle) * stars_distance * (1-mass_ratio),
			stars_distance * (1 - mass_ratio - 0.35),
			depth + 1,
			velocity + Vector2.from_angle(angle + clockwise) * net_velocity * (1-mass_ratio)
			)
		add_bodies(
			(1 - mass_ratio) * mass,
			centre + Vector2.from_angle(angle) * stars_distance * mass_ratio,
			stars_distance * (mass_ratio - 0.35),
			depth + 1,
			velocity + Vector2.from_angle(angle + clockwise) * net_velocity * mass_ratio
			)
	else:
		# Exit case
		var density: float = DENSITIES[clampi(depth, 0, 6)]
		radius = generate_body(mass, centre, velocity, density)
	
	if moon_mass != 0.0:
		# Moons
		# Set count
		var moon_count: int = max(ceil(log(moon_mass) / log(50)) + randf() - randf() - randf(), 0)
		# Set randoms
		var moons: PackedFloat32Array = []
		moons.resize(moon_count + 1)
		for i in moon_count:
			moons[i] = randf()
		moons[moon_count] = 1
		moons.sort()
		var last: float = 0
		for i in moon_count:
			var proportion: float = moons[i] - last
			last = moons[i]
			var distance_from_body: float = randf_range(radius + 0.1 * max_radius, max_radius)
			var angle: float = randf_range(0, TAU)
			add_bodies(
				proportion * moon_mass, 
				centre + Vector2.from_angle(angle) * distance_from_body,
				max_radius / moon_count,
				depth + 1,
				velocity + Vector2.from_angle(angle + clockwise) * sqrt(mass * BIG_G / distance_from_body)
				)


func generate_body(mass: float, position: Vector2, velocity: Vector2, density: float) -> float:
	# Pass most values.
	# Cube root of 3m/4πd = r
	var r = pow(3 * mass / (2 * TAU * density), 1.0 / 3.0)
	add_body(mass, r, position.x, position.y, 0.0, velocity.x, velocity.y)
	return r
