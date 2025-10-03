extends Node2D

@export var colour: = Color.WHITE
@export var count : Array[int] = [2,7,19,31,37,17,11,3]
@export var first_radius : int = 43
@export var radius_per_layer : float = 5
@export var arc_gap_length : float = 5

@export var line_width := -1.0
@export var draw_outer_circle := true


func _ready() -> void:
	for i in len(count):
		# Instantiate
		var node:Node2D = Node2D.new()
		add_child(node, false, Node.INTERNAL_MODE_FRONT)
		# Connect draw call with bound arguments to draw signal
		node.draw.connect(draw_arc_layer.bind(count[i], first_radius + radius_per_layer * i, node))
		# Set random rotation
		node.rotation = randf_range(0, TAU)


func _process(delta: float) -> void:
	# Rotate all children
	for i in get_child_count(true):
		get_child(i, true).rotate(2 * delta / (i + 2))


func draw_arc_layer(num:int, distance:float, node:Node2D):
	for i in num:
		# Draw arc from i*TAU/num to (i+1)*TAU/num, with a gap of arc_gap_length
		node.draw_arc(
			Vector2.ZERO,
			distance,
			i * TAU / num,
			(i + 1) * TAU / num - (arc_gap_length / distance),
			8,
			colour,
			line_width)


func _draw() -> void:
	if draw_outer_circle:
		draw_circle(Vector2.ZERO, 88, colour, false)
