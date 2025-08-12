class_name Body extends Area2D


var radius: float:
	set(v):
		var shape = CircleShape2D.new()
		shape.radius = v
		get_child(0).shape = shape
		radius = v
		for i in $Predictions.get_children():
			i.get_child(0).shape = shape
var id: int:
	set(v):
		for i in $Predictions.get_children():
			i.set_meta("id", v)
		set_meta("id", v)
		id = v


func set_prediction(index: int, pos: Vector2):
	$Predictions.get_child(index - 1).position = pos


func _draw():
	draw_circle(Vector2.ZERO, radius, "f5e8d1")
