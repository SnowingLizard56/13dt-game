extends Node2D

@export var strand_count := 15
@export var radius := 88.0
@export var inner_radius := 15.0
@export var delta_r := 5.0
@export var sector_dist := 0.15
@export var strand_speed_magnitude := 0.4

@export var colour := Color.WHITE

@export var time_min := 3.0
@export var time_max := 7.0

var strand_angles: PackedFloat32Array = []
var strand_speeds: PackedFloat32Array = []


func _ready() -> void:
	strand_angles.resize(strand_count)
	strand_speeds.resize(strand_count)
	for i in strand_count:
		strand_angles[i] = randf() * TAU
		strand_speeds[i] = randf_range(-1, 1) * strand_speed_magnitude
		var t = Timer.new()
		add_child(t)
		t.wait_time = randf_range(time_min, time_max)
		t.timeout.connect(replace_strand.bind(i))
		t.start()


func _process(delta: float) -> void:
	for i in strand_count:
		strand_angles[i] += strand_speeds[i] * delta
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, colour, false)
	draw_circle(Vector2.ZERO, inner_radius, colour)
	for n in strand_count:
		var angle: float = strand_angles[n]
		var point: Vector2 = Vector2.from_angle(angle) * radius
		var polyline: PackedVector2Array = [point]
		
		for i in ceilf((radius - inner_radius) / delta_r):
			point = Vector2.from_angle(angle + randf_range(-1, 1) * sector_dist) * (radius - (i + 1) * delta_r)
			polyline.append(point)
		draw_polyline(polyline, colour)


func replace_strand(i:int) -> void:
	get_child(i).wait_time = randf_range(time_min, time_max)
	strand_angles[i] = randf() * TAU
	strand_speeds[i] = randf_range(-1, 1) * strand_speed_magnitude
