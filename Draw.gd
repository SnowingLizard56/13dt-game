extends Node2D

var data: Array[Dictionary]

func _draw() -> void:
	for i in data:
		draw_circle(Vector2(i.x, i.y), i.r, Color.WHITE)
