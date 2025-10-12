class_name EnemyGenerator extends Node

const FLYING_ENEMY: PackedScene = preload("res://Actors/Enemies/Flying/flying_enemy.tscn")
const CANNON_ENEMY: PackedScene = preload("res://Actors/Enemies/Cannon/cannon_enemy.tscn")
const HANGAR_ENEMY: PackedScene = preload("res://Actors/Enemies/Hangar/hangar_enemy.tscn")
const TENDRIL_ENEMY: PackedScene = preload("res://Actors/Enemies/Tendril/tendril_enemy.tscn")
const LOOSE_ENEMY_LIMIT: int = 64
const LOOSE_ENEMY_HARD_LIMIT: int = 256

const ENEMY_TYPES: Array[PackedScene] = [CANNON_ENEMY, HANGAR_ENEMY, TENDRIL_ENEMY]
const ENEMY_LAYOUTS: Array[PackedInt32Array] = [
	[0, 0, 0],
	[1, 1, 1],
	[0, 0, 0, 1],
	[0, 0, 2, 2],
	[2, 2, 1],
	[2, 1, 2, 0],
	[2, 2, 2, 2]
]

@export var enemy_put_node: Node2D
@onready var flying_spawn_zone: Path2D = $FlyingEnemySpawnZone
@onready var root: LevelController = Global.root


var total_enemies_alive: int = 0
var average_enemy_position: Vector2


func _on_game_initial_areas_instantiated() -> void:
	for id in root.areas:
		for idx in ENEMY_LAYOUTS.pick_random():
			var k: Enemy = ENEMY_TYPES[idx].instantiate()
			k.body_id = id
			k.gen = self
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


func _process(_delta: float) -> void:
	total_enemies_alive = get_tree().get_nodes_in_group("enemies").size()
	
	var p := Vector2.ZERO
	for i in get_tree().get_nodes_in_group("enemies"):
		p += Vector2(i.x, i.y)
	average_enemy_position = p / total_enemies_alive
# Anselwozhere
