extends Node2D

var level: Level
var game_rect: Rect2

@onready var player: Player = %Player
@onready var camera: Camera2D = %Camera


func _ready() -> void:
	await LevelGenerator.level_generated
	level = LevelGenerator.get_ready_level()
	add_child(level)


func _process(delta: float) -> void:
	if level:
		level.step(delta * 10000)
		
		game_rect = camera.get_viewport_rect()
		game_rect.size /= camera.zoom.x
		
		game_rect.position = Vector2(player.player_x, player.player_y) - game_rect.size / 2
		queue_redraw()


func _draw() -> void:
	if level:
		for b in level.get_bodies():
			draw_circle(Vector2(b.x - player.player_x, b.y - player.player_y), b.r, Color.WHITE)
