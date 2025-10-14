# Unused
extends Area2D

const DEBRIS_COLOUR := Color(1, 0.937255, 0.631373, 1)
@onready var x: float = position.x
@onready var y: float = position.y
var vx: float = 0
var vy: float = 0

@onready var root: LevelController = get_tree().current_scene


func _physics_process(delta: float) -> void:
	if not root.level: return
	var grav: Dictionary = root.level.barnes_hut_probe(Global.time_scale, x, y)
	vx += grav.ax * delta
	vy += grav.ay * delta
	x += vx * delta
	y += vy * delta
	position = Vector2(x - root.player.x, y - root.player.y)


func _process(delta: float) -> void:
	rotate(-delta)


func _draw() -> void:
	const VERTEX_COUNT: int = 12
	var pts: PackedVector2Array = []
	var angs: PackedFloat32Array = []
	var dists: PackedFloat32Array = []
	pts.resize(VERTEX_COUNT)
	angs.resize(VERTEX_COUNT)
	dists.resize(VERTEX_COUNT)
	for i in VERTEX_COUNT:
		# Random 90th of TAU
		angs[i] = randi_range(0, 90) * TAU/90
	for i in VERTEX_COUNT:
		dists[i] = 12 - randf() * 5
	angs.sort()
	var centroid: Vector2 = Vector2.ZERO
	for i in VERTEX_COUNT:
		var dist: float = sqrt(randf()) * 5 + 5
		pts[i] = Vector2.from_angle(angs[i]) * dist
		centroid += pts[i]
	centroid /= VERTEX_COUNT
	for i in VERTEX_COUNT:
		pts[i] -= centroid
	draw_colored_polygon(pts, DEBRIS_COLOUR)
