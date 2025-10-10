class_name ThrustParticleProfile extends Resource

@export var amount: int
@export var lifetime: float
@export var speed_min: float
@export var speed_max: float
@export var spread: float
@export var color: Color
@export var color_intitial_ramp: Gradient


func apply(emitter: CPUParticles2D):
	emitter.spread = spread
	emitter.amount = amount
	emitter.color_initial_ramp = color_intitial_ramp
	emitter.lifetime = lifetime
	emitter.anim_speed_min = speed_min
	emitter.anim_speed_max = speed_max
