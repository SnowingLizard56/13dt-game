class_name EnemyGenerator extends Node

const FLYING_ENEMY: PackedScene = preload("res://Actors/Enemies/Flying/flying_enemy.tscn")
const CANNON_ENEMY: PackedScene = preload("res://Actors/Enemies/Cannon/cannon_enemy.tscn")
const HANGAR_ENEMY: PackedScene = preload("res://Actors/Enemies/Hangar/hangar_enemy.tscn")
const TENDRIL_ENEMY: PackedScene = preload("res://Actors/Enemies/Tendril/tendril_enemy.tscn")
const LOOSE_ENEMY_LIMIT: int = 64
const LOOSE_ENEMY_HARD_LIMIT: int = 256

const ENEMY_TYPES: Array[PackedScene] = [CANNON_ENEMY, HANGAR_ENEMY, TENDRIL_ENEMY]
const ENEMY_LAYOUTS: Array[PackedInt32Array] = [
	[0, 0, 0, 1], # Cannon x3, Hangar x1
	[0, 0, 2, 2], # Cannon x2, Tendril x2
	[2, 1, 2, 0],
	[2, 2, 2, 2],
	[0, 0, 0],
	[1, 1, 1],
	[2, 2, 1],
]

@export var enemy_put_node: Node2D
@onready var root: LevelController = Global.root

var total_enemies_alive: int = 0


func _on_game_initial_areas_instantiated() -> void:
	for id in root.areas:
		if id == 0 and not GlobalOptions.spawn_enemies_mid():
			continue
		
		# Choose layout, add each enemy in it
		for idx in ENEMY_LAYOUTS.pick_random():
			var k: Enemy = ENEMY_TYPES[idx].instantiate()
			k.body_id = id
			k.gen = self
			root.areas[id].add_child(k)


func _process(_delta: float) -> void:
	total_enemies_alive = get_tree().get_nodes_in_group("enemies").size()

# Anselwozhere
