extends Node2D

var level: Level
var game_rect: Rect2

@onready var player: Player = %Player
@onready var camera: Camera2D = %Camera


func _ready() -> void:
	await LevelGenerator.level_generated
	level = LevelGenerator.get_ready_level()
	add_child(level)
	#for i in level.get_bodies():
		#var k: Area2D = Area2D.new()


func _process(delta: float) -> void:
	if level:
		level.naive_step(delta * Global.time_scale)
		
		game_rect = camera.get_viewport_rect()
		game_rect.size /= camera.zoom.x
		
		game_rect.position = Vector2(player.x, player.y) - game_rect.size / 2
		queue_redraw()


func _draw() -> void:
	if level:
		for b in level.get_bodies():
			draw_circle(Vector2(b.x - player.x, b.y - player.y), b.r, Color.WHITE)
