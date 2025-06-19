extends Node2D

@export var colour: Color = Color.WHITE
@export var radius := 88
var num: int

@export var line_width := -1.0


func _process(delta:float) -> void:
	rotate(delta/16)
	# Update texture
	queue_redraw()


func _draw() -> void:
	num = 2*int(1000*Time.get_unix_time_from_system())+1
	var points : PackedVector2Array = []
	# Get binary representation
	var string : String = String.num_int64(num, 2)
	# Iterate over it
	for i in len(string):
		if string[i] == "1":
			# If bit is on, then draw connection to this point
			points.append(Vector2.from_angle(7*i*TAU/64-TAU/4)*radius)
	# Draw line
	draw_polyline(points, colour, line_width)
	# Draw outline
	draw_circle(Vector2.ZERO, radius, colour, false, line_width + 1)
