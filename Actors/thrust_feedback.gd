extends Node2D

var active: bool
var target_rotation: float:
	set(v):
		active = true
		target_rotation = v


func _process(delta: float) -> void:
	queue_redraw()
	global_rotation = lerp_angle(global_rotation, target_rotation, 0.3)


func _draw() -> void:
	if active:
		for i in 10:
			pass
