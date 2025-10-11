class_name FlyingEnemy extends Enemy

const SPRITE: PackedVector2Array = [
	Vector2(8, 0),
	Vector2(-5, -5),
	Vector2(-2, 0),
	Vector2(-5, 5),
]

# Visual only
const MAX_TURN_SPEED: float = TAU
# Actually important
const MAX_THRUST: float = 120
const PLAYER_STOP_APPROACHING: float = 300
const PLAYER_RUN_AWAY: float = 100
const ORBIT_SPEED: float = 127
const ORBIT_THRUST_PROPORTION: float = 0.31
const PROJECTILE_SPEED: float = 175
const MAX_HP: float = 50
const INACCURACY: float = 0.02 * TAU
const SEPARATION: float = 50
const KILL_DISTANCE: float = 4000
const PROJECTILE_MASS: float = 4.0

@onready var path: Node2D = $PathPrediction

var can_shoot: bool = true
@onready var time_until_shoot_attempt: float = randf() + randf()


enum MovementModes {
	UNASSIGNED = -1,
	AVOID_BODY,
	APPROACH_PLAYER,
	MATCH_PLAYER,
	ORBIT_PLAYER,
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
	
	var mode: MovementModes = MovementModes.UNASSIGNED
	if colliding_idx != -1:
		mode = MovementModes.AVOID_BODY
	else:
		var player_dist: float = (x - root.player.x) ** 2 + (y - root.player.y) ** 2
		if player_dist < PLAYER_STOP_APPROACHING ** 2:
			# Within range: we are alg. no need to move too much
			mode = MovementModes.MATCH_PLAYER
		else:
			# Out of range: something gotta change
			var vel_diff: float = (root.player.vx - vx) ** 2 + (root.player.vy - vy) ** 2
			if MAX_THRUST * 2 * sqrt(player_dist) < vel_diff:
				# Decelerate, approach velocity of player
				mode = MovementModes.MATCH_PLAYER
			else:
				# Accelerate, approach position of player
				mode = MovementModes.APPROACH_PLAYER
	
	match mode:
		MovementModes.AVOID_BODY:
			# Uh oh uh oh uh oh. run away from scary circle
			var collided_area: Area2D = path.get_child(colliding_idx).get_collider()
			if not collided_area:
				target_thrust = Vector2.ZERO
			else:
				var b: Dictionary = root.level.get_body(collided_area.get_meta(&"id"))
				
				var coll_pos: Vector2 = Vector2(b.x, b.y)
				var me_rel_coll: Vector2 = Vector2(x, y) + \
					path.get_child(colliding_idx).position - coll_pos
				var pred_rel_coll: Vector2 = me_rel_coll + path.get_child(colliding_idx).target_position

				var angle_to_pred: float = me_rel_coll.angle_to(pred_rel_coll)

				target_thrust = me_rel_coll.rotated(sign(angle_to_pred) * TAU/4)
		
		MovementModes.MATCH_PLAYER:
			if position.length_squared() < PLAYER_RUN_AWAY ** 2:
				target_thrust = position
			else:
				target_thrust = Vector2(root.player.vx - vx, root.player.vy - vy)
		
		MovementModes.APPROACH_PLAYER:
			if position.is_zero_approx():
				target_thrust = Vector2.UP
			elif Vector2(vx - root.player.vx, vy - root.player.vy).slide(position.normalized()
				).length_squared() ** 2 / position.length_squared() > MAX_THRUST ** 2:
				target_thrust = Vector2(root.player.vx - vx, root.player.vy - vy)
			else:
				target_thrust = -position
	
	for i in $FindFriends.get_overlapping_areas():
		var friend = i.get_parent()
		if friend is FlyingEnemy:
			target_thrust += (position - friend.position).normalized() * SEPARATION
	
	var thrust: Vector2 = target_thrust.limit_length(MAX_THRUST)
	
	if thrust != Vector2.ZERO:
		var theta_diff = angle_difference(get_child(0).rotation, target_thrust.angle())
		get_child(0).rotation += sign(theta_diff) * min(abs(theta_diff), MAX_TURN_SPEED * delta)
	
	vx += (grav.ax + thrust.x) * delta
	vy += (grav.ay + thrust.y) * delta
	x += vx * delta
	y += vy * delta
	position = Vector2(x - root.player.x, y - root.player.y)
	
	# Attempt Projectile Generation
	if position.length_squared() > KILL_DISTANCE ** 2:
		queue_free()
	if position.length_squared() < PLAYER_STOP_APPROACHING ** 2 \
	and position.length_squared() > PLAYER_RUN_AWAY ** 2:
		time_until_shoot_attempt -= delta
		if time_until_shoot_attempt < 0:
			time_until_shoot_attempt = randf_range(3, 6)
			if can_shoot:
				var projectile_speed: Vector2 = (-position + delta *
					Vector2(root.player.vx, root.player.vy))\
					.normalized().rotated((randf() - randf()) * INACCURACY) * PROJECTILE_SPEED
				var projectile_shape := CircleShape2D.new()
				projectile_shape.radius = 3
				var p := Projectile.new(
					self, 
					projectile_speed.x,
					projectile_speed.y,
					projectile_shape,
					PROJECTILE_MASS
					)
				p.x = x + vx * delta
				p.y = y + vy * delta
	
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
		cast.target_position = vel_offset * Global.PREDICTION_TIMESTEP * 3
		
		cast_start += vel_offset * Global.PREDICTION_TIMESTEP


func draw_sprite() -> void:
	get_child(0).draw_colored_polygon(SPRITE, current_colour)


func collide_with_planet(_area: Area2D) -> void:
	_area.crash_particles(_area.position.angle_to_point(position))
	queue_free()
