class_name Laser extends Node2D

const COLOUR := Projectile.COLOUR
@export var cast: ShapeCast2D
var weapon: LaserWeapon
@onready var shape: RectangleShape2D = cast.shape

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
var laser_end := 1000
var active = true


func _ready() -> void:
	global_rotation = Global.aim.angle()
	cast.position = CIRCLE_POS
	var t := get_tree().create_tween()
	t.tween_property(self, "width", weapon.width, PHASE_1_TIME)
	t.parallel().tween_property(self, "theta", TAU * (weapon.sustain + PHASE_3_TIME) / PERIOD,
		weapon.sustain + PHASE_3_TIME)
	await get_tree().create_timer(weapon.sustain).timeout
	active = false
	t = get_tree().create_tween()
	t.tween_property(self, "width", 0, PHASE_3_TIME)
	queue_free()


func _process(delta: float) -> void:
	if active:
		# Collisions, damage
		laser_end = cast.target_position.x
		for i in cast.get_collision_count():
			var hit = cast.get_collider(i)
			var target: Node = null
			if hit:
				target = hit.get_parent()
			
			if target is Enemy:
				target.damage(delta * weapon.dps)
			elif target is Body:
				laser_end = to_local(cast.get_collision_point(i)).length() - CIRCLE_POS.x
				break
		# Rotate
		var diff := angle_difference(global_rotation, Global.aim.angle())
		rotate(sign(diff) * min(abs(diff), weapon.rotate_speed * delta))
	# Draw, Collision
	queue_redraw()
	shape.size.y = width


func _draw() -> void:
	draw_circle(CIRCLE_POS, RADIUS_PROPORTION * width, COLOUR)
	draw_rect(
		Rect2(CIRCLE_POS - Vector2(0, width), Vector2(laser_end, width * 2)),
		COLOUR
	)
