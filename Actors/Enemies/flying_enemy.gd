class_name FlyingEnemy extends Node2D

const SPRITE: PackedVector2Array = [
	Vector2(8, 0),
	Vector2(-5, -5),
	Vector2(-2, 0),
	Vector2(-5, 5),
]

@onready var x: float = position.x
@onready var y: float = position.y
var vx: float = 0
var vy: float = 0

var max_ω: float = TAU
var max_thrust: float = 120

@onready var root: LevelController = get_tree().current_scene


func _physics_process(delta: float) -> void:
	if !root.level: return
	var grav: Dictionary = root.level.barnes_hut_probe(Global.time_scale, x, y)
	
	# Cast Resolution
	var colliding_idx: int
	for i: int in 8:
		if $PathPrediction.get_child(i).is_colliding():
			colliding_idx = i
			break
	
	var target_thrust: Vector2 = Vector2.ZERO
	
	if colliding_idx:
		var average_position := Vector2.ZERO
		for i in 8:
			average_position += $PathPrediction.get_child(0).target_position
		average_position /= 8
		
		var collided_area: Area2D = $PathPrediction.get_child(colliding_idx).get_collider()
		var b: Dictionary = root.level.get_body(collided_area.get_meta(&"id"))
		
		var coll_pos: Vector2 = Vector2(b.x, b.y)
		var me_rel_coll: Vector2 = Vector2(x, y) - coll_pos
		var avg_rel_coll: Vector2 = me_rel_coll + average_position
		
		var angle_to_avg: float = me_rel_coll.angle_to(avg_rel_coll)
		
		target_thrust = me_rel_coll.rotated(sign(angle_to_avg) * TAU/4)
	else:
		# TODO - seek player
		pass
	
	
	var thrust: Vector2 = target_thrust.limit_length(max_thrust)
	
	if thrust != Vector2.ZERO:
		var theta_diff = angle_difference(get_child(0).rotation, target_thrust.angle())
		get_child(0).rotation += sign(theta_diff) * min(abs(theta_diff), max_ω * delta)
	
	vx += (grav.ax + thrust.x) * delta
	vy += (grav.ay + thrust.y) * delta
	x += vx * delta
	y += vy * delta
	
	position = Vector2(x - root.player.x, y - root.player.y)

	# Reset PathPrediction Casts
	var next_grav: Dictionary = grav.duplicate()
	var cast_start: Vector2 = Vector2.ZERO
	var vel_offset: Vector2 = Vector2(vx, vy)
	
	for i: int in 8:
		var cast: RayCast2D = $PathPrediction.get_child(i)
		if i != 0:
			next_grav = root.get_prediction(i * 5.0 / 8).barnes_hut_probe(
				Global.time_scale, x + cast_start.x, y + cast_start.y)
		
		cast.position = cast_start
		vel_offset += Vector2(next_grav.ax, next_grav.ay)
		cast.target_position = vel_offset * 5.0/8
		
		cast_start += cast.target_position


func draw_sprite() -> void:
	get_child(0).draw_colored_polygon(SPRITE, "dd5639")


func collide_with_planet(area: Area2D) -> void:
	queue_free()
