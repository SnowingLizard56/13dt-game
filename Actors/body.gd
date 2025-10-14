class_name Body extends Area2D

const COLOUR := Color(0.960784, 0.909804, 0.819608, 1)

@onready var predictions: Node2D = $Predictions
@onready var particles: CPUParticles2D = $CrashParticles

var radius: float:
	set(v):
		var shape = CircleShape2D.new()
		shape.radius = v
		get_child(0).shape = shape
		radius = v
		for i in predictions.get_children():
			i.get_child(0).shape = shape
var id: int:
	set(v):
		for i in predictions.get_children():
			i.set_meta("id", v)
		set_meta("id", v)
		id = v


func is_clear():
	# If any enemies are inhabiting this planet, return false
	for i in get_children():
		if i is Enemy:
			return false
	return true


func set_prediction(index: int, pos: Vector2):
	predictions.get_child(index - 1).position = pos


func _draw():
	draw_circle(Vector2.ZERO, radius, COLOUR)


func crash_particles(angle: float):
	var emitter: CPUParticles2D = particles.duplicate()
	emitter.position = Vector2.from_angle(angle) * radius
	emitter.rotation = angle
	emitter.emitting = true
	emitter.finished.connect(emitter.queue_free)
	add_child(emitter)


func release_enemies() -> Array[Enemy]:
	# Prepare for queue_free
	var out: Array[Enemy]
	for i in get_children():
		if i is Enemy:
			remove_child(i)
			out.append(i)
	return out
