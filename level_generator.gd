extends Node

const STORE_LEVELS := 2

@onready var thread: Thread = Thread.new()
var levels_ready: Array[Level]

signal made_one


func _ready() -> void:
	# DEBUG
	thread.start(thread_main)


func thread_main() -> void:
	while true:
		# Every second
		# Looking for a version of this that blocks
		if len(levels_ready) < STORE_LEVELS:
			# If levels_ready < STORE_LEVELS
			# Add GravityController
			var level = Level.new()
			# Set values for gravitycontroller
			level.distribute_bodies()
			# Do simulations to get to playable point
			for i in 10:
				level.barnes_hut_step(5.0, 0.5)
			
			for i in 500:
				level.barnes_hut_step(1.0, 1.0)
			
			for i in 500:
				level.barnes_hut_step(0.2, 1.2)
			
			for i in 500:
				level.barnes_hut_step(0.1, 0.8)
			
			level.clamp_to_circle(level.distribution_radius)
			
			while level:
				break
			# Increment levels_ready
			levels_ready.append(level)
			made_one.emit.call_deferred()


# level loading thread communicates with game using this
func return_data(data: Array[Dictionary], i: int) -> void:
	get_child(i).data = data
	get_child(i).queue_redraw()
