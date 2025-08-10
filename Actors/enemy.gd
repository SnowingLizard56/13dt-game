extends Area2D

const SPRITE: PackedVector2Array = [
	Vector2(8, 0),
	Vector2(-5, -5),
	Vector2(-2, 0),
	Vector2(-5, 5)
]

var x: float
var y: float
var vx: float = 0
var vy: float = 0

var max_ω: float = TAU

@onready var levelcontroller: LevelController = get_tree().current_scene


func _physics_process(delta: float) -> void:
	var target_rotation: float = 0
	var target_thrust: float = 0
	# TODO - figure out target rotation
	var theta_diff = angle_difference(rotation, target_rotation)
	
	rotation += sign(theta_diff) * min(abs(theta_diff), max_ω*delta)
	
	var grav: Dictionary = levelcontroller.level.barnes_hut_probe(Global.time_scale, x, y)
	vx += grav.ax * delta
	vy += grav.ay * delta
	x += vx * delta
	y += vy * delta


func _draw() -> void:
	draw_colored_polygon(SPRITE, "dd5639")
