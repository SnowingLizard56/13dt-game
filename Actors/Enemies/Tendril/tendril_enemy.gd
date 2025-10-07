class_name TendrilEnemy extends Enemy

const MAX_HP := 240.0
const SEGMENT_LENGTH := 50.0
const SEGMENTS_MIN := 4
const SEGMENTS_MAX := 8
const SEGMENT_MAX_ROTATION := TAU * 0.1
const ACCELERATION := TAU * 0.1
const LENGTH_OSC_AMPLITUDE := 7.5
const DAMAGE := 20.0

@export var hitbox: Area2D
var segments: int = 0
var rotations: PackedFloat32Array = []
var v_rotations: PackedFloat32Array = []
var frequencies: PackedFloat32Array
var time: float = 0.0
var length_mult := 1.0
var active := true


func _ready() -> void:
	super()
	segments = randi_range(SEGMENTS_MIN, SEGMENTS_MAX)
	rotations.resize(segments)
	v_rotations.resize(segments)
	frequencies.resize(segments)
	rotations.fill(0)
	v_rotations.fill(0)
	for i in segments:
		frequencies[i] = randf_range(0.1, 0.25)
		var k = CollisionShape2D.new()
		hitbox.add_child(k)
		k.shape = SegmentShape2D.new()


func _physics_process(delta: float) -> void:
	var start := Vector2.ZERO
	var relpos := Vector2(x, y)
	var rotsum := 0.0
	time += delta
	for i in hitbox.get_child_count():
		# Shape ref
		var shape: SegmentShape2D = hitbox.get_child(i).shape
		# Acceleration
		var target_angle = (shape.a + relpos).angle_to_point(Vector2(root.player.x, root.player.y)) - rotsum
		var diff = angle_difference(rotations[i] + rotation, target_angle)
		v_rotations[i] += sign(diff) * ACCELERATION * delta
		# Velocity
		rotations[i] += v_rotations[i] * delta
		# Handle borders to prevent spinning
		var rotation_sign = sign(rotations[i])
		if abs(rotations[i]) > SEGMENT_MAX_ROTATION:
			# If past max rotattion, clamp and bounce
			rotations[i] = rotation_sign * SEGMENT_MAX_ROTATION
			v_rotations[i] = 0
		# Connect
		shape.a = start
		# Next position
		shape.b = shape.a + Vector2.from_angle(rotations[i] + rotsum)\
			* (SEGMENT_LENGTH + LENGTH_OSC_AMPLITUDE * sin(TAU * frequencies[i] * time)) * length_mult
		# For next
		start = shape.b
		rotsum += rotations[i]
	queue_redraw()


func _draw() -> void:
	for i in hitbox.get_children():
		draw_line(i.shape.a, i.shape.b, current_colour, 10)


func death_override():
	const SHRINK_TIME := 0.7
	active = false
	# Dont look. PLEASE
	hitbox.collision_layer = 0
	hitbox.collision_mask = 0
	# Animation
	var t := get_tree().create_tween()
	t.tween_property(self, "length_mult", 0.0, SHRINK_TIME)
	await get_tree().create_timer(SHRINK_TIME).timeout
	super()


func _on_segments_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		area.get_parent().damage(DAMAGE, 4)
