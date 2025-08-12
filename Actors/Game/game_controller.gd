class_name LevelController extends Node2D

var level: Level
var game_rect: Rect2

@onready var player: Player = %Player
@onready var camera: Camera2D = %Camera

var quad_tl: Vector2i = -Vector2i.ONE

var areas: Dictionary[int, Area2D] = {}
var predictions: Dictionary[int, Level] = {}

@export var body_scene: PackedScene


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
		predictions = {0: level}
		game_rect.position = Vector2(player.x, player.y) - game_rect.size / 2
		update_areas()
		queue_redraw()


func update_areas() -> void:
	for b in level.get_bodies():
		if !areas.has(b.id):
			var k: Body = body_scene.instantiate()
			areas[b.id] = k
			k.id = b.id
			k.radius = b.r
			$Bodies.add_child(k)
			
		areas[b.id].position = Vector2(b.x - player.x, b.y - player.y)


func delete_body_area(old_id: int, _new_id: int) -> void:
	areas[old_id].queue_free()
	areas.erase(old_id)


func get_prediction(pred_idx: int) -> Level:
	if predictions.has(pred_idx):
		return predictions[pred_idx]
	
	var out: Level = level.duplicate()
	
	for i in predictions[pred_idx - 1].get_bodies():
		out.add_body(i.m, i.r, i.x, i.y, i.vx, i.vy)
	out.barnes_hut_step(pred_idx * Global.time_scale * Global.PREDICTION_TIMESTEP, 2.0)
	
	predictions[pred_idx] = out
	
	for idx in level.get_live_body_count():
		var body_pred: Dictionary = out.get_body(idx)
		var body_real: Dictionary = level.get_body(areas.keys()[idx])
		areas[areas.keys()[idx]].set_prediction(
			pred_idx, 
			Vector2(body_pred.x - body_real.x, body_pred.y - body_real.y)
			)
	
	return out
