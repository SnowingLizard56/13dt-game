class_name BackgroundQuad extends Node2D

var grid_pos: Vector2i
var player: Player

var layer: BackgroundParallaxController.Layer
const MIN := 3.0
const MAX := 8.0


func _init() -> void:
	process_priority = 1


func _draw() -> void:
	Global.random.seed = grid_pos.x + grid_pos.y * 2 ** 16 + Global.level_seed + layer.layer_seed
	# This is an overcomplicated way of drawing a random number of stars
	var count: float =  Global.random.randf_range(MIN, MAX)
	while count > 0:
		count -= pinprick(Vector2(
			Global.random.randf_range(0, layer.game_size.x),
			Global.random.randf_range(0, layer.game_size.y)))


func pinprick(pos: Vector2) -> float:
	draw_circle(
		pos,
		1,
		Color.WHITE
		)
	return 0.5
