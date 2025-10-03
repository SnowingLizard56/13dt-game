extends Node

const STORE_LEVELS := 1

@onready var thread: Thread = Thread.new()
var levels_ready: Array[Level]
var generating
var read_data: Array[Dictionary]

signal level_generated


func _ready() -> void:
	thread.start(thread_main)


func thread_main() -> void:
	while true:
		if len(levels_ready) < STORE_LEVELS:
			# If levels_ready < STORE_LEVELS
			# Add GravityController
			var level = Level.new()
			
			level.distribute_bodies()
			
			# Increment levels_ready
			levels_ready.append(level)
			level_generated.emit.call_deferred()
		OS.delay_msec(1000)


func get_ready_level() -> Level:
	return levels_ready.pop_front()
