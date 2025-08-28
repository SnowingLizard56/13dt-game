class_name EnemyGenerator extends Node

const FLYING_ENEMY: PackedScene = preload("res://Actors/Enemies/Flying/flying_enemy.tscn")
const CANNON_ENEMY: PackedScene = preload("res://Actors/Enemies/Cannon/cannon_enemy.tscn")
const LOOSE_ENEMY_LIMIT: int = 64
const LOOSE_ENEMY_HARD_LIMIT: int = 256

@export var enemy_put_node: Node2D
@onready var flying_spawn_zone: Path2D = $FlyingEnemySpawnZone
@onready var root: LevelController = Global.root

var total_enemies_alive: int = 0


func _on_game_initial_areas_instantiated() -> void:
	for id in root.areas:
		var k = CANNON_ENEMY.instantiate()
		k.body_id = id
		root.areas[id].add_child(k)


func _on_flying_enemy_spawn_attempt_timer_timeout() -> void:
	if enemy_put_node.get_child_count() >= LOOSE_ENEMY_LIMIT:
		$FlyingEnemySpawnAttemptTimer.start()
		return
	
	var pos: Vector2 = flying_spawn_zone.curve.sample_baked(
		flying_spawn_zone.curve.get_baked_length() * randf())
	for i in randi_range(3, 12):
		var k: FlyingEnemy = FLYING_ENEMY.instantiate()
		enemy_put_node.add_child(k)
		var shimmy := Vector2(randf_range(-15, 15), randf_range(-15, 15))
		k.vx = root.player.vx
		k.vy = root.player.vy
		k.x = root.player.x + pos.x + shimmy.x - k.vx * get_process_delta_time()
		k.y = root.player.y + pos.y + shimmy.y - k.vy * get_process_delta_time()
	$FlyingEnemySpawnAttemptTimer.start(randf_range(18, 60))
