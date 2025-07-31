class_name LevelController extends Node2D

var level: Level
var game_rect: Rect2

@onready var player: Player = %Player
@onready var camera: Camera2D = %Camera

var areas: Dictionary[int, Area2D] = {}

var quad_tl: Vector2i = -Vector2i.ONE


func _ready() -> void:
	get_tree().paused = true
	await LevelGenerator.level_generated
	get_tree().paused = false
	level = LevelGenerator.get_ready_level()
	level.body_collided.connect(delete_body_area)
	add_child(level)
	update_areas()
	player.x = level.player_spawn_x
	player.y = level.player_spawn_y
	player.vx = level.player_spawn_vx
	player.vy = level.player_spawn_vy
	
	game_rect = camera.get_viewport_rect()
	game_rect.size /= camera.zoom.x
	
	get_node("Background").new_layer(0.005)
	get_node("Background").new_layer(0.007)
	get_node("Background").new_layer(0.01)
	get_node("Background").new_layer(0.02)
	get_node("Background").new_layer(0.025)


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		pass
	else:
		level.naive_step(delta * Global.time_scale)
		
		game_rect.position = Vector2(player.x, player.y) - game_rect.size / 2
		update_areas()
		queue_redraw()


func update_areas() -> void:
	for b in level.get_bodies():
		if !areas.has(b.id):
			areas[b.id] = Area2D.new()
			add_child(areas[b.id])
			var col: CollisionShape2D = CollisionShape2D.new()
			var shape: CircleShape2D = CircleShape2D.new()
			shape.radius = b.r
			col.shape = shape
			areas[b.id].add_child(col)
			areas[b.id].collision_layer = 2
			areas[b.id].collision_mask = 0
			areas[b.id].draw.connect(areas[b.id].draw_circle.bind(
				Vector2.ZERO,
				b.r,
				"f5e8d1"
				))
			areas[b.id].set_meta("id", b.id)
		areas[b.id].position = Vector2(b.x - player.x, b.y - player.y)


func delete_body_area(old_id: int, _new_id: int) -> void:
	areas[old_id].queue_free()
	areas.erase(old_id)
