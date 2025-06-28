extends Node

const STORE_LEVELS := 1

@onready var thread: Thread = Thread.new()
var levels_ready: Array[Level]
var generating

signal made_one


func _ready() -> void:
	# DEBUG
	thread.start(thread_main)


func thread_main() -> void:
	while true:
		if len(levels_ready) < STORE_LEVELS:
			var tick = Time.get_ticks_msec()
			# If levels_ready < STORE_LEVELS
			# Add GravityController
			var level = Level.new()
			# Set values for gravitycontroller
			level.distribute_bodies()
			# A few big steps to get the ~ball~ nebula ~rollin~ spinnin
			for i in 200:
				level.barnes_hut_step(5.0)
			# And step until only some bodies are left
			while len(level.get_sentinel_ids()) < 1001:
				# Get time step required for max speed to move 0.5px
				return_data.call_deferred(level.get_bodies())
				for i in 40:
					level.barnes_hut_step(10.0)
			
			return_data.call_deferred(level.get_bodies())
			# Increment levels_ready
			levels_ready.append(level)
			made_one.emit.call_deferred()
		OS.delay_msec(1000000)


# level loading thread communicates with game using this
func return_data(data: Array[Dictionary]) -> void:
	get_child(0).data = data
	get_child(0).queue_redraw()

func get_ready_level() -> Level:
	return levels_ready.pop_front()
