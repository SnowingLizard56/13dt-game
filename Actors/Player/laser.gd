class_name Laser extends Node2D

const COLOUR := Projectile.COLOUR
const TICK_TIME := 0.3
@export var cast: RayCast2D
@export var coll: CollisionShape2D
@export var hitbox: Area2D
var weapon: LaserWeapon
@onready var shape: RectangleShape2D = coll.shape
@onready var tick: Timer = $Tick

var width := 0.0:
	get():
		return max(width + AMPLITUDE * sin(theta), 0)
var theta := 0.0

const RADIUS_PROPORTION := 1.1
const PHASE_1_TIME := 0.3
const PHASE_3_TIME := 0.5
const PERIOD := 0.4
const AMPLITUDE := 1.0

const CIRCLE_POS := Vector2(25, 0)
var laser_end := 1000.0
var active = true


func _ready() -> void:
	tick.wait_time = TICK_TIME
	shape = RectangleShape2D.new()
	coll.shape = shape
	_process(0)
	global_rotation = Global.aim.angle()
	cast.position = CIRCLE_POS
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "width", weapon.width, PHASE_1_TIME)
	tween.parallel().tween_property(self, "theta", TAU * (weapon.sustain + PHASE_3_TIME) / PERIOD,
		weapon.sustain + PHASE_3_TIME)
	await get_tree().create_timer(weapon.sustain).timeout
	active = false
	tween = get_tree().create_tween()
	tween.tween_property(self, "width", 0, PHASE_3_TIME)
	tween.tween_callback(queue_free)


func _process(delta: float) -> void:
	if active:
		laser_end = 1000
		# Shaping
		if cast.is_colliding():
			laser_end = cast.get_collision_point().length()
		coll.position = Vector2(shape.size.x / 2 + CIRCLE_POS.x, 0)
		# Rotate
		var diff := angle_difference(global_rotation, Global.aim.angle())
		rotation_degrees += sign(diff) * min(abs(diff), weapon.rotate_speed * delta)
	# Draw, Collision
	queue_redraw()
	shape.size = Vector2(laser_end - CIRCLE_POS.x, width * 2)


func _draw() -> void:
	draw_circle(CIRCLE_POS, RADIUS_PROPORTION * width, COLOUR)
	draw_rect(
		Rect2(CIRCLE_POS - Vector2(0, width), Vector2(laser_end, width * 2)),
		COLOUR
	)


func by_distance(a: Enemy, b: Enemy):
	return a.global_position.length_squared() <= b.global_position.length_squared()


func _on_tick_timeout() -> void:
	for i in hitbox.get_overlapping_areas().size():
		var target: Enemy = hitbox.get_overlapping_areas()[i].get_parent()
		target.damage(weapon.dps * TICK_TIME)
