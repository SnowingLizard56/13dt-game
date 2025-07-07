class_name Level extends GravityController

const DENSITIES: PackedFloat64Array = [1.2e7, 4.8e7, 9.6e7, 1.2e8, 2.8e7, 0.9e7]
const MIN_MOONS: PackedInt32Array = [4, 1, 0, 0, 0]
const MAX_MOONS: PackedInt32Array = [8, 4, 2, 1, 0]
const BIG_G: float = 6.67e-11
const WELL_STRENGTH_CUTOFF: float = 1e-7


var total_mass: float
var clockwise: float


func _init() -> void:
	# Randomly generate some parameters
	total_mass = 11 ** (15 + randf() - randf())
	do_collision = true
	distance_scale = 1000
	if randi_range(0, 1) == 0:
		clockwise = TAU / 4
	else:
		clockwise = -TAU / 4


func distribute_bodies() -> void:
	add_bodies(total_mass, Vector2.ZERO, Vector2.ZERO, 0, 1800, 0, true)


# This function is recursive
func add_bodies(mass: float, centre: Vector2, velocity: Vector2, min_radius: float, max_radius: float, depth: int, add_moons: bool) -> void:
	# DEBUG - print(mass, " ", centre, " ", max_radius, " ", depth, " ", velocity)
	# Max depth. No moons.
	var moon_mass: float = 0.0
	if depth <= 0 and (depth <= 1 or randf() < 0.91) and add_moons:
		moon_mass = mass * randf_range(0.013, 0.031)
		mass -= moon_mass
	# Main bodies
	if mass / total_mass >= 0.097 and add_moons and randf() < 0.03:
		# Binary+
		var mass_ratio: float = randf_range(0.41, 0.61)
		var stars_distance: float = randf_range(0.69, 0.87) * max_radius * 2
		# Gotta do a little maths
		var net_velocity: float = sqrt(mass * BIG_G / stars_distance) / distance_scale
		var angle: float = randf_range(0, TAU)
		# greatest influence of the two stars
		min_radius = stars_distance * max(mass_ratio, 1 - mass_ratio)
		#max_radius = max(
			#stars_distance * (1 - mass_ratio) + sqrt(mass_ratio * mass),
			#stars_distance * mass_ratio + sqrt((1 - mass_ratio) * mass))
		
		# Call add_bodies for each new body. Args follow:
		# Proprtion of mass
		# Current centre plus offset
		# Current velocity plus relative
		# sqrt
		# hm
		# Current depth +1
		# No moons on each from binary
		
		add_bodies(
			mass_ratio * mass,
			centre + Vector2.from_angle(angle) * stars_distance * (1-mass_ratio),
			velocity + Vector2.from_angle(angle + clockwise) * net_velocity * (1-mass_ratio),
			0,
			0,
			depth,
			false
			)
		add_bodies(
			(1 - mass_ratio) * mass,
			centre + Vector2.from_angle(PI + angle) * stars_distance * mass_ratio,
			velocity + Vector2.from_angle(PI + angle + clockwise) * net_velocity * mass_ratio,
			0,
			0,
			depth,
			false
			)
	else:
		# Exit case
		var density: float = DENSITIES[clampi(depth, 0, 6)]
		min_radius = generate_body(mass, centre, velocity, density) * 2
		max_radius = min(max_radius, sqrt(mass) / distance_scale)
	
	if moon_mass != 0.0:
		# Moons
		# Set count
		var moon_count: int = randi_range(MIN_MOONS[depth], MAX_MOONS[depth])
		#var moon_count = 1
		print(depth, " ", moon_count)
		# Set randoms
		var moon_masses: PackedFloat64Array = []
		moon_masses.resize(moon_count + 1)
		# Get maasses
		for i in moon_count:
			moon_masses[i] = randf()
		moon_masses[moon_count] = 1
		moon_masses.sort()
		var moon_influences: PackedFloat64Array = []
		moon_influences.resize(moon_count + 1)
		
		# Get influences and set mass values
		var last: float = 0
		for i in moon_count:
			var proportion: float = moon_masses[i] - last
			last = moon_masses[i]
			moon_masses[i] = proportion * moon_mass
			moon_influences[i] = sqrt(proportion * moon_mass * BIG_G / WELL_STRENGTH_CUTOFF) / distance_scale
			
		
		# Arrange moon distances
		var moon_distances: PackedFloat64Array = []
		moon_distances.resize(moon_count + 1)
		
		for i in moon_count:
			if i > 0:
				moon_distances[i] = min_radius + moon_influences[i] + moon_influences[i - 1]
			else:
				moon_distances[i] = min_radius + moon_influences[i]
			min_radius = moon_distances[i]
		
		# Make them
		for i in moon_count:
			var angle: float = randf_range(0, TAU)
			add_bodies(
				moon_masses[i], 
				centre + Vector2.from_angle(angle) * moon_distances[i],
				velocity + Vector2.from_angle(angle + clockwise) * sqrt(mass * BIG_G / moon_distances[i]) / distance_scale,
				0, 
				0,
				depth + 1,
				true
				)
			pass


func generate_body(mass: float, position: Vector2, velocity: Vector2, density: float) -> float:
	# Pass most values.
	# Cube root of 3m/4πd = r
	var r = pow(3 * mass / (2 * TAU * density), 1.0 / 3.0)
	if r > 1:
		add_body(mass, r, position.x, position.y, 0.0, velocity.x, velocity.y)
	return r
