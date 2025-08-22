extends Node2D

@export var radius := 88.0
@export var number := 12
@export var min_blob_radius := 18.0
@export var max_blob_radius := 36.0
@export var outer_ring_dist := 7.0
@export var min_speed := 4e-3
@export var max_speed := 7e-3
@export var colour := Color.WHITE
@export var subglob_number := 50

var speeds: PackedFloat32Array = []


func _ready() -> void:
	for i in number:
		var k: Node2D = Node2D.new()
		add_child(k)
		k.draw.connect(draw_blob.bind(k))
		speeds.append(randf_range(min_speed, max_speed))


func _process(delta: float) -> void:
	for i in number:
		get_child(i).rotate(speeds[i])


func draw_blob(node: Node2D) -> void:
	node.rotation = randf_range(0, TAU)
	var distance: float = randf() * radius - outer_ring_dist - max_blob_radius
	var radius: float = randf_range(min_blob_radius, max_blob_radius)
	for i in subglob_number:
		var subglob_position = Vector2(distance, 0) + Vector2.from_angle(
			randf_range(0, TAU)) * sqrt(randf()) * radius
		node.draw_circle(subglob_position, 1, colour)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, colour, false)
