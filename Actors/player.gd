class_name Player extends Area2D

const SPRITE_RADIUS: int = 5

signal player_died

# Fun fact! floats are stored with double precision,
# while floats that are part of Vector2s are single precision.
var x: float = 750.0
var y: float = 750.0
var vx: float = 0.0
var vy: float = 0.0

var level: Level

#@onready var ship: Ship = Global.player_ship
@export var ship: Ship


var trigger_queue: PackedInt32Array = []
var trigger_timer_queue: PackedFloat32Array = []


func add_to_trigger_queue(id: int):
	if not id in trigger_queue:
		trigger_queue.append(id)
		if trigger_timer_queue:
			trigger_timer_queue.append(0.05)
		else:
			trigger_timer_queue.append(0.0)


func _ready() -> void:
	ship.set_components()


func _process(delta: float) -> void:
	# Triggers
	if Input.is_action_pressed("trigger_1"):
		add_to_trigger_queue(0)
	if Input.is_action_pressed("trigger_2"):
		add_to_trigger_queue(1)
	if Input.is_action_pressed("trigger_3"):
		add_to_trigger_queue(2)
	if Input.is_action_pressed("trigger_4"):
		add_to_trigger_queue(3)
	
	if trigger_timer_queue:
		trigger_timer_queue[0] -= delta
		if trigger_timer_queue[0] <= 0.0:
			ship.trigger(trigger_queue[0], self)
			trigger_queue.remove_at(0)
			trigger_timer_queue.remove_at(0)


func _physics_process(delta: float) -> void:
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
	
	var grav: Dictionary = level.barnes_hut_probe(Global.time_scale, x, y, 1.0, 0.0)
	vx += grav.ax * delta
	vy += grav.ay * delta
	
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
