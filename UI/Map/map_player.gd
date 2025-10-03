class_name MapPlayer extends Node2D

const RADIUS := 38.0
const GAP := TAU * 0.1
const PLAYER_COLOUR := Color("20a5a6")
const PLAYER_RADIUS := 10.0
const OUTER_SPEED := TAU * 0.125
const INNER_SPEED := TAU * 0.2
const MOVE_TIME := 0.5

@onready var child: Node2D = get_child(0)

signal destination_reached
var my_icon: MapIcon


func _draw() -> void:
	draw_arc(Vector2.ZERO, RADIUS, GAP / 2,  TAU - GAP / 2, 32, PLAYER_COLOUR, 1.0)


func _on_player_draw() -> void:
	child.position = Vector2(RADIUS, 0)
	child.draw_rect(
		Rect2(Vector2.ONE * -PLAYER_RADIUS / 2, Vector2.ONE * PLAYER_RADIUS),
		PLAYER_COLOUR
		)


func _process(delta: float) -> void:
	rotate(delta * OUTER_SPEED)
	child.rotate(delta * INNER_SPEED)
	if not my_icon:
		return
	scale = Vector2.ONE * my_icon.scale_val / my_icon.SCALE_NORMAL


func move_to(target: MapIcon):
	var t := get_tree().create_tween()
	t.tween_property(self, "position", target.position + target.SCALE_NORMAL * target.size / 2, MOVE_TIME)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	t.tween_callback(destination_reached.emit)
	await destination_reached
	my_icon = target
	target.queue_redraw()
