# Unused
extends Camera2D

var noise: FastNoiseLite
var trauma: float = 0.0
var trauma_exp: float = 2.0
var noise_y: int = 0

@export var decay := 1.2
@export var max_offset = 7.5
@export var max_rotation = 0.07


func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_VALUE


func _process(delta: float) -> void:
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()


func shake():
	noise_y += 1
	var amount = pow(trauma, trauma_exp)
	offset.x = max_offset * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.y = max_offset * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	rotation = max_rotation * amount * noise.get_noise_2d(noise.seed * 3, noise_y)
