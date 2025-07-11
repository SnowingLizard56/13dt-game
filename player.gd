class_name Player extends Node2D

const SPRITE_RADIUS: int = 5

# floats are stored with double precision.
var player_x: float = 0.0
var player_y: float = 0.0
var player_xv: float = 0.0
var player_yv: float = 0.0

var acceleration: float = 200.0

@onready var ship: Array[ShipComponent] = Global.player_ship


func _process(delta: float) -> void:
	rotate(-delta)
	# Take input
	var acceleration_input = Vector2(
		Input.get_axis("player_left", "player_right"),
		Input.get_axis("player_up", "player_down")
	).normalized()
	
	# Velocity then position
	player_xv += acceleration * acceleration_input.x * delta
	player_yv += acceleration * acceleration_input.y * delta
	
	if get_parent().level:
		var gravity: Dictionary = get_parent().level.probe(delta * 1e8, player_x, player_y)
		if gravity.has("collision_id"):
			pass
		else:
			player_xv += gravity.ax
			player_yv += gravity.ay
	
	player_x += player_xv * delta
	player_y += player_yv * delta


func _draw() -> void:
	var sq_pts: PackedVector2Array = [
		Vector2(SPRITE_RADIUS, SPRITE_RADIUS),
		Vector2(-SPRITE_RADIUS, SPRITE_RADIUS),
		Vector2(-SPRITE_RADIUS, -SPRITE_RADIUS),
		Vector2(SPRITE_RADIUS, -SPRITE_RADIUS)
	]
	draw_colored_polygon(sq_pts, Color("20a5a6"))
