extends Node2D

var data: Array[Dictionary]
var level: Level = null


func _draw() -> void:
	for i in data:
		draw_circle(Vector2(i.x, i.y), i.r, Color.WHITE)


func _process(delta: float) -> void:
	if level:
		level.naive_step(delta)
		data = level.get_bodies()
		queue_redraw()
