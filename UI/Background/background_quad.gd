class_name BackgroundQuad extends Node2D

var grid_pos: Vector2i
var player: Player

var layer: BackgroundParallaxController.Layer


enum DecorationGroup {
	DISTANT,
}

var decoration_groups: Array[Array] = [
	[pinprick, hole],
]
const DECORATION_WEIGHTS: Array[Array] = [
	[5, 0],
]


func _ready() -> void:
	process_priority = 1


func _draw() -> void:
	Global.random.seed = grid_pos.x + grid_pos.y * 2**16 + Global.level_seed + layer.layer_seed
	var count: float =  Global.random.randf_range(3, 8)
	while count > 0:
		var idx: int = Global.random.rand_weighted(DECORATION_WEIGHTS[layer.group])
		count -= decoration_groups[layer.group][idx].call(Vector2(
			Global.random.randf_range(0, layer.game_size.x),
			Global.random.randf_range(0, layer.game_size.y)))


func pinprick(pos: Vector2) -> float:
	draw_circle(
			pos,
			1,
			Color.WHITE
			)
	return 0.5


func hole(pos: Vector2) -> float:
	draw_circle(
		pos,
		5,
		Color.BLACK
	)
	return 8
