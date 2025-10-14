class_name BackgroundParallaxController extends Node2D

var layers: Array[Layer] = []
@onready var player: Player = %Player


func new_layer(factor: float) -> Layer:
	var layer := Layer.new()
	
	for i in [-Vector2i.ONE, Vector2i.UP, Vector2i.LEFT, Vector2i.ZERO]:
		var q: BackgroundQuad = BackgroundQuad.new()
		q.grid_pos = i
		q.layer = layer
		add_child(q)
		layer.quads.append(q)
	
	layer.game_size = get_parent().game_rect.size
	layer.parallax_factor = factor
	layers.append(layer)
	return layer


func _process(_delta: float) -> void:
	for i in layers:
		i.update_position(player)


class Layer:
	# Subclass to handle each quarter of the background
	var layer_seed: int = randi() % 2 ** 32
	var parallax_factor: float = 1.0
	var quads: Array[BackgroundQuad] = []
	var game_size: Vector2
	
	func update_position(player:Player):
		for i in quads:
			i.position = Vector2(
				i.grid_pos.x * game_size.x - parallax_factor * player.x,
				i.grid_pos.y * game_size.y - parallax_factor * player.y
			)
		var corner: Vector2 = quads[0].position + game_size
		# Eugh. This is bulky. Necessary though
		if corner.x < -game_size.x / 2:
			# Swap l/r, new l needs queue redraw
			quads[0].queue_redraw()
			quads[2].queue_redraw()
			quads[0].grid_pos.x += 2
			quads[2].grid_pos.x += 2
			
			var temp: BackgroundQuad = quads[0]
			quads[0] = quads[1]
			quads[1] = temp
			temp = quads[2]
			quads[2] = quads[3]
			quads[3] = temp
		elif corner.x > game_size.x / 2:
			# Swap l/r, new r needs queue redraw
			quads[1].queue_redraw()
			quads[3].queue_redraw()
			quads[1].grid_pos.x -= 2
			quads[3].grid_pos.x -= 2
			
			var temp: BackgroundQuad = quads[0]
			quads[0] = quads[1]
			quads[1] = temp
			temp = quads[2]
			quads[2] = quads[3]
			quads[3] = temp
		
		if corner.y < -game_size.y / 2:
			# Swap t/b, new t needs queue redraw
			quads[0].queue_redraw()
			quads[1].queue_redraw()
			quads[0].grid_pos.y += 2
			quads[1].grid_pos.y += 2
			
			var temp: BackgroundQuad = quads[0]
			quads[0] = quads[2]
			quads[2] = temp
			temp = quads[1]
			quads[1] = quads[3]
			quads[3] = temp
		elif corner.y > game_size.y / 2:
			# Swap t/b, new b needs queue redraw
			quads[2].queue_redraw()
			quads[3].queue_redraw()
			quads[2].grid_pos.y -= 2
			quads[3].grid_pos.y -= 2
			
			var temp: BackgroundQuad = quads[0]
			quads[0] = quads[2]
			quads[2] = temp
			temp = quads[1]
			quads[1] = quads[3]
			quads[3] = temp
