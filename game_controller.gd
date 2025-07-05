extends Node2D


func _ready() -> void:
	await LevelGenerator.level_generated
	add_child(LevelGenerator.get_ready_level())
