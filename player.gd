class_name Player extends Node2D

const SPRITE_RADIUS: int = 5

signal player_died

# floats are stored with double precision. Vector2s are single precision.
var x: float = 500.0
var y: float = 500.0
var xv: float = 00.0
var yv: float = 00.0

var acceleration: float = 200.0

var level: Level

@onready var ship: Ship = Global.player_ship


func _process(delta: float) -> void:
	rotate(-delta)
	# Take input
	var acceleration_input = Vector2(
		Input.get_axis("player_left", "player_right"),
		Input.get_axis("player_up", "player_down")
	).normalized()
	
	# Velocity then position
	xv += acceleration * acceleration_input.x * delta
	yv += acceleration * acceleration_input.y * delta
	
	if !level:
		level = get_parent().level
	
	var gravity: Dictionary = level.barnes_hut_probe(delta * Global.time_scale ** 2, x, y, 1.0, 0.0)
	if gravity.has("collision_id"):
		player_died.emit()
		get_tree().paused = true
	else:
		xv += gravity.ax
		yv += gravity.ay
	
	x += xv * delta
	y += yv * delta


func _draw() -> void:
	var sq_pts: PackedVector2Array = [
		Vector2(SPRITE_RADIUS, SPRITE_RADIUS),
		Vector2(-SPRITE_RADIUS, SPRITE_RADIUS),
		Vector2(-SPRITE_RADIUS, -SPRITE_RADIUS),
		Vector2(SPRITE_RADIUS, -SPRITE_RADIUS)
	]
	draw_colored_polygon(sq_pts, Color("20a5a6"))
