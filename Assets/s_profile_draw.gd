extends Node2D

@export var radius := 88
@onready var starting_num : int = 3


func _process(delta:float) -> void:
	# Increment display number by 01001
	starting_num += 18
	# Update texture
	queue_redraw()


func _draw() -> void:
	var points : PackedVector2Array = []
	var string : String = String.num_int64(starting_num, 2)
	for i in len(string):
		if string[i] == "1":
			# If bit is on, then draw connection to this point
			points.append(Vector2.from_angle(i*TAU/(len(string) - 1)-TAU/4)*radius)
	# Draw line
	draw_polyline(points, Color.WHITE)
	# Draw outline
	draw_circle(Vector2.ZERO, radius, Color.WHITE, false)
