class_name Body extends Area2D


var radius: float:
	set(v):
		var shape = CircleShape2D.new()
		shape.radius = v
		get_child(0).shape = shape
		radius = v
		for i in $Predictions.get_children():
			i.get_child(0).shape = shape
var id: int:
	set(v):
		for i in $Predictions.get_children():
			i.set_meta("id", v)
		set_meta("id", v)
		id = v


func _ready() -> void:
	Global.root.level.body_collided.connect(_on_collision)


func is_clear():
	for i in get_children():
		if i is Enemy:
			return false
	return true


func set_prediction(index: int, pos: Vector2):
	$Predictions.get_child(index - 1).position = pos


func _draw():
	draw_circle(Vector2.ZERO, radius, "f5e8d1")


func crash_particles(angle: float):
	var emitter: CPUParticles2D = $CrashParticles.duplicate()
	emitter.position = Vector2.from_angle(angle) * radius
	emitter.rotation = angle
	emitter.emitting = true
	emitter.finished.connect(emitter.queue_free)
	add_child(emitter)


func _on_collision(from: int, to: int):
	if to == id:
		# Prepare for expand
		pass
	elif from == id:
		# Prepare for queue_free
		#for i in get_children():
			#if i is Enemy:
				#i.reparent_body(to)
		pass
