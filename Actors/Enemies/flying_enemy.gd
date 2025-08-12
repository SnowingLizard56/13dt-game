class_name FlyingEnemy extends Node2D

const SPRITE: PackedVector2Array = [
	Vector2(8, 0),
	Vector2(-5, -5),
	Vector2(-2, 0),
	Vector2(-5, 5),
]


# Visual only
const MAX_ω: float = TAU
# Actually important
const MAX_THRUST: float = 120
const PLAYER_STOP_APPROACHING: float = 10

@onready var root: LevelController = get_tree().current_scene

@onready var x: float = position.x
@onready var y: float = position.y
@onready var path: Node2D = $PathPrediction

var vx: float = 0
var vy: float = 0
enum MovementModes {
	AVOID_BODY,
	APPROACH_PLAYER,
	MATCH_PLAYER,
}


func _physics_process(delta: float) -> void:
	if !root.level: return
	var grav: Dictionary = root.level.barnes_hut_probe(Global.time_scale, x, y)
	# Cast Resolution
	var colliding_idx: int = -1
	for i: int in 8:
		if path.get_child(i).is_colliding():
			colliding_idx = i
			break
	
	var target_thrust: Vector2 = Vector2.ZERO
	
	var mode: MovementModes = -1
	if colliding_idx != -1:
		mode = MovementModes.AVOID_BODY
	else:
		var player_dist: float = (x - root.player.x) ** 2 + (y - root.player.y) ** 2
		if player_dist < PLAYER_STOP_APPROACHING ** 2:
			# Within range: we are alg. no need to move too much
			# TODO
			pass
		else:
			# Out of range: something gotta change
			var vel_diff: float = (root.player.vx ** 2 - vx ** 2) ** 2 + (root.player.vy ** 2 - vy ** 2) ** 2
			if MAX_THRUST * 4 * player_dist < vel_diff:
				# Decelerate, approach velocity of player
				mode = MovementModes.MATCH_PLAYER
			else:
				# Accelerate, approach position of player
				mode = MovementModes.APPROACH_PLAYER
		
		
		var target_velocity
	
	match mode:
		MovementModes.AVOID_BODY:
			# Uh oh uh oh uh oh. run away from scary circle
			var collided_area: Area2D = path.get_child(colliding_idx).get_collider()
			var b: Dictionary = root.level.get_body(collided_area.get_meta(&"id"))
			
			var coll_pos: Vector2 = Vector2(b.x, b.y)
			var me_rel_coll: Vector2 = Vector2(x, y) + path.get_child(colliding_idx).position - coll_pos
			var pred_rel_coll: Vector2 = me_rel_coll + path.get_child(colliding_idx).target_position

			var angle_to_pred: float = me_rel_coll.angle_to(pred_rel_coll)

			target_thrust = me_rel_coll.rotated(sign(angle_to_pred) * TAU/4)
		
		MovementModes.MATCH_PLAYER:
			target_thrust = Vector2(root.player.vx - vx, root.player.vy - vy)
		
		MovementModes.APPROACH_PLAYER:
			target_thrust = -position
	
	
	var thrust: Vector2 = target_thrust.limit_length(MAX_THRUST)
	
	if thrust != Vector2.ZERO:
		var theta_diff = angle_difference(get_child(0).rotation, target_thrust.angle())
		get_child(0).rotation += sign(theta_diff) * min(abs(theta_diff), MAX_ω * delta)
	
	vx += (grav.ax + thrust.x) * delta
	vy += (grav.ay + thrust.y) * delta
	x += vx * delta
	y += vy * delta
	
	position = Vector2(x - root.player.x, y - root.player.y)

	# Reset PathPrediction Casts
	var next_grav: Dictionary = grav.duplicate()
	var cast_start: Vector2 = Vector2.ZERO
	var vel_offset: Vector2 = Vector2(vx, vy) * Global.PREDICTION_TIMESTEP
	
	for i: int in 8:
		var cast: RayCast2D = path.get_child(i)
		if i != 0:
			next_grav = root.get_prediction(i).barnes_hut_probe(
				Global.time_scale, x + cast_start.x, y + cast_start.y)
		
		cast.position = cast_start
		vel_offset += Vector2(next_grav.ax, next_grav.ay) * Global.PREDICTION_TIMESTEP
		cast.target_position = vel_offset * Global.PREDICTION_TIMESTEP
		
		cast_start += cast.target_position


func draw_sprite() -> void:
	get_child(0).draw_colored_polygon(SPRITE, "dd5639")


func collide_with_planet(area: Area2D) -> void:
	queue_free()
