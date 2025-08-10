class_name Level extends E127Controller

const DENSITIES: PackedFloat64Array = [1.1e6, 1.3e6]
const BIG_G: float = 6.67e-11
const WELL_STRENGTH_CUTOFF: float = BIG_G * 80


var total_mass: float
var clockwise: float

var player_spawn_x: float
var player_spawn_y: float
var player_spawn_vx: float
var player_spawn_vy: float


func _init() -> void:
	# Randomly generate some parameters
	total_mass = 10 ** randf_range(14.25, 14.75)
	distance_scale = 10000
	if randi_range(0, 1) == 0:
		clockwise = TAU / 4
	else:
		clockwise = -TAU / 4


func distribute_bodies() -> void:
	add_bodies(total_mass, Vector2.ZERO, Vector2.ZERO, 0, 1)


func add_bodies(mass: float, centre: Vector2, velocity: Vector2, min_radius: float, max_radius: float) -> void:
	var moon_mass: float = mass * randf_range(0.13, 0.19)
	mass -= moon_mass
	
	# Main body
	var density: float = DENSITIES[0]
	min_radius = generate_body(mass, centre, velocity, density) * 2
	max_radius = min(max_radius, sqrt(mass) / distance_scale)
	
	# Moons
	# Set count
	var moon_count: int = 6
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
	
	var star_radius: float = min_radius
	
	for i in moon_count:
		if i > 0:
			moon_distances[i] = min_radius + moon_influences[i] + moon_distances[i - 1]
			
		else:
			moon_distances[i] = min_radius + moon_influences[i]
		min_radius = moon_distances[i]
	
	# Make them
	var first_moon_radius: float
	for i in moon_count:
		var pos_angle: float = randf_range(0, TAU)
		var radius: float = generate_body(
			moon_masses[i], 
			centre + Vector2.from_angle(pos_angle) * moon_distances[i],
			velocity + Vector2.from_angle(pos_angle + clockwise) * sqrt(mass * BIG_G / moon_distances[i]) / distance_scale,
			DENSITIES[1]
		)
		if !first_moon_radius:
			first_moon_radius = radius
	
	var distance: float = star_radius + (moon_distances[0] - first_moon_radius - star_radius) / 2
	var angle: float = randf_range(0, TAU)
	
	player_spawn_x = cos(angle) * distance
	player_spawn_y = sin(angle) * distance
	
	var vel: float = sqrt(mass * BIG_G / distance) * 42
	player_spawn_vx = cos(angle + clockwise) * vel
	player_spawn_vy = sin(angle + clockwise) * vel


func generate_body(mass: float, position: Vector2, velocity: Vector2, density: float) -> float:
	# Pass most values.
	# Cube root of 3m/4πd = r
	var r = pow(3 * mass / (2 * TAU * density), 1.0 / 3.0)
	if r > 1:
		add_body(mass, r, position.x, position.y, velocity.x, velocity.y)
	return r
