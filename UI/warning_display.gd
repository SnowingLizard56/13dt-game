extends Control

const COLOUR := Color("ffefa1")
const SIDE_LENGTH := 20
const CURVE_RADIUS := 5

var top: Vector2
var left: Vector2
var right: Vector2
var pts: PackedVector2Array


func _ready() -> void:
	top = SIDE_LENGTH * Vector2(0.5, -sin(TAU / 6))
	left = Vector2(CURVE_RADIUS, -top.y + CURVE_RADIUS)
	top += left
	right = left + Vector2(SIDE_LENGTH, 0)
	pts = [
		top + CURVE_RADIUS * Vector2(cos(TAU / 12), -0.5),
		top + CURVE_RADIUS * Vector2(-cos(TAU / 12), -0.5),
		left + CURVE_RADIUS * Vector2(-cos(TAU / 12), -0.5),
		left + CURVE_RADIUS * Vector2(0, 1),
		right + CURVE_RADIUS * Vector2(0, 1),
		right + CURVE_RADIUS * Vector2(cos(TAU / 12), -0.5),
	]
	size = right + CURVE_RADIUS * Vector2.ONE
	position -= size / 2
	get_child(0).position += Vector2(size.x, size.y / 2)


func _draw() -> void:
	# Triangle
	for pos in [top, left, right]:
		draw_circle(pos, CURVE_RADIUS, COLOUR)
	# Hexagon but weird
	draw_colored_polygon(pts, COLOUR)
	# Exclamation Mark
	draw_circle(Vector2(top.x, 8), 3, Color.BLACK)
	draw_circle(Vector2(top.x, 13), 2, Color.BLACK)
	draw_colored_polygon(
		[
			Vector2(top.x - 3, 8),
			Vector2(top.x + 3, 8),
			Vector2(top.x + 2, 13),
			Vector2(top.x - 2, 13),
		],
		Color.BLACK
		)
	draw_circle(Vector2(top.x, 20), 2, Color.BLACK)
