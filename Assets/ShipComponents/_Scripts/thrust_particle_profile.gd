class_name ThrustParticleProfile extends Resource

@export var amount: int
@export var lifetime: float
@export var speed_min: float
@export var speed_max: float
@export var spread: float
@export var color: Color
@export var color_intitial_ramp: Gradient


func apply(emitter: CPUParticles2D) -> CPUParticles2D:
	var k := emitter.duplicate()
	emitter.add_sibling(k)
	emitter.emitting = false
	emitter.finished.connect(emitter.queue_free)
	k.emitting = true
	
	k.spread = spread
	k.amount = amount
	k.color = color
	k.color_initial_ramp = color_intitial_ramp
	k.lifetime = lifetime
	k.anim_speed_min = speed_min
	k.anim_speed_max = speed_max
	return k
