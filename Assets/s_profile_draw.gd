extends Node2D

@export var radius := 88
var num: int


func _process(delta:float) -> void:
	# Increment display number by 01001
	num = 2*int(1000*Time.get_unix_time_from_system())+1
	# Update texture
	queue_redraw()


func _draw() -> void:
	var points : PackedVector2Array = []
	var string : String = String.num_int64(num, 2)
	for i in len(string):
		if string[i] == "1":
			# If bit is on, then draw connection to this point
			points.append(Vector2.from_angle(12*i*TAU/67-TAU/4)*radius)
	# Draw line
	draw_polyline(points, Color.WHITE)
	# Draw outline
	draw_circle(Vector2.ZERO, radius, Color.WHITE, false)
