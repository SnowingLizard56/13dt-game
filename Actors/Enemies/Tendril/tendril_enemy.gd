class_name TendrilEnemy extends Enemy

const MAX_HP := 170.0
const SEGMENT_LENGTH := 10.0
const SEGMENTS_MIN := 3
const SEGMENTS_MAX := 6
const SEGMENT_MAX_ROTATION := TAU * 0.3

@export var hitbox: Area2D
var segments: int
var rotations: PackedFloat32Array
var v_rotations: PackedFloat32Array


func _ready() -> void:
	segments = randi_range(SEGMENTS_MIN, SEGMENTS_MAX)
	rotations.resize(segments)
	v_rotations.resize(segments)
	rotations.fill(0)
	v_rotations.fill(0)
	for i in segments - 1:
		var k = hitbox.get_child(0).duplicate()
		hitbox.add_child(k)


func _process(delta: float) -> void:
	var start := Vector2.ZERO
	for i in hitbox.get_child_count():
		var shape: SegmentShape2D = hitbox.get_child(i).shape
		shape.a = start
		
		shape.b = Vector2.from_angle(rotations[i]) * SEGMENT_LENGTH
		
		start = shape.b


func _draw() -> void:
	for i in hitbox.get_children():
		draw_line(i.shape.a, i.shape.b, ENEMY_COLOUR)
