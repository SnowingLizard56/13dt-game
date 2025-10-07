extends Control

const RADIUS := 2.5
const ENEMY_COLOUR := Color(0.866667, 0.337255, 0.223529, 1)
const ROTATION_SPEED := TAU * 0.15
var clear_theta := 0.0
@export var distance_modulate: Gradient

func _process(delta: float) -> void:
	clear_theta += ROTATION_SPEED * delta
	queue_redraw()


func _draw() -> void:
	var rect: Rect2 = get_rect()
	for e: Enemy in get_tree().get_nodes_in_group("enemies"):
		var theta: float = e.global_position.angle() 
		var radius: float
		# Thank you stackoverflow.
		# I simplified it though
		if abs(tan(theta)) < rect.size.y / rect.size.x:
			radius = rect.size.x / (2 * cos(theta))
		else:
			radius = rect.size.y / (2 * sin(theta))
		if e.global_position.length_squared() < radius ** 2:
			continue
		var pos = e.global_position.limit_length(abs(radius))
		var distance_from_clear = abs(angle_difference(theta, clear_theta)) / PI
		var colour := ENEMY_COLOUR
		colour.a = distance_modulate.sample(distance_from_clear).a
		
		draw_circle(pos + rect.size / 2, RADIUS, colour)
