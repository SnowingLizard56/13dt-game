class_name Player extends Area2D

const SPRITE_RADIUS: int = 5

signal player_died

# floats are stored with double precision. Vector2s are single precision.
var x: float = 750.0
var y: float = 750.0
var vx: float = 0.0
var vy: float = 0.0

var level: Level

#@onready var ship: Ship = Global.player_ship
@export var ship: Ship


func _ready() -> void:
	ship.set_components()


func _physics_process(delta: float) -> void:
	# Triggers
	if Input.is_action_just_pressed("trigger_1"):
		ship.trigger(0, self)
	if Input.is_action_just_pressed("trigger_2"):
		ship.trigger(1, self)
	if Input.is_action_just_pressed("trigger_3"):
		ship.trigger(2, self)
	if Input.is_action_just_pressed("trigger_4"):
		ship.trigger(3, self)
	
	# Take input
	var acceleration_input = Vector2(
		Input.get_axis("player_left", "player_right"),
		Input.get_axis("player_up", "player_down")
	).normalized()
	# Visual
	rotate(-delta * ship.acceleration / 80)
	if acceleration_input:
		get_node("AccelerationFeedback").target_rotation = acceleration_input.angle()
	else:
		get_node("AccelerationFeedback").active = false
	
	# Velocity then position
	vx += ship.acceleration * acceleration_input.x * delta
	vy += ship.acceleration * acceleration_input.y * delta
	
	if !level:
		level = get_parent().level
	
	var grav: Dictionary = level.barnes_hut_probe(delta * Global.time_scale ** 2, x, y, 1.0, 0.0)
	vx += grav.ax
	vy += grav.ay
	
	x += vx * delta
	y += vy * delta


func _draw() -> void:
	var sq_pts: PackedVector2Array = [
		Vector2(SPRITE_RADIUS, SPRITE_RADIUS),
		Vector2(-SPRITE_RADIUS, SPRITE_RADIUS),
		Vector2(-SPRITE_RADIUS, -SPRITE_RADIUS),
		Vector2(SPRITE_RADIUS, -SPRITE_RADIUS)
	]
	draw_colored_polygon(sq_pts, Color("20a5a6"))


func _on_area_entered(area: Area2D) -> void:
	if area.collision_layer == 2:
		# Bounce off. Come back to this  MAYBE
		# DEPRECATED
		#var body: Dictionary = level.get_body(area.get_meta("id"))
		#var player_v: Vector2 = Vector2(vx - body.vx, vy - body.vy)
		#var penetration: Vector2 = player_v.limit_length(body.r - area.position.length())
		#var normal: Vector2 = (area.position - penetration).normalized()
		#var perpendicular: Vector2 = normal.rotated(TAU/4)
		#
		#var velocity_diff: Vector2 = 2 * player_v.project(normal)
		#var position_diff: Vector2 = penetration - 2 * penetration.project(perpendicular)
		#vx -= velocity_diff.x
		#vy -= velocity_diff.y
		#x -= position_diff.x
		#x -= position_diff.x
		
		# Kill
		player_died.emit()
		get_tree().paused = true
