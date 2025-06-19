extends Node2D

@export var colour: = Color.WHITE
@export var count : Array[int] = [2,7,19,31,37,17,11,3]
@export var radius : int = 24
@export var radius_per_layer : int = 8

@export var line_width := -1.0


func _ready() -> void:
	for i: int in 8:
		# Instantiate
		var node:Node2D = Node2D.new()
		add_child(node, false, Node.INTERNAL_MODE_FRONT)
		# Connect bound call
		node.draw.connect(draw_line_layer.bind(count[i], radius + i*radius_per_layer, node))
		# Set rotation
		node.rotation = randf_range(0, TAU)


func _process(delta: float) -> void:
	# Rotate children
	for i: int in get_child_count(true):
		get_child(i, true).rotate(2*delta/(i+2))


func draw_line_layer(count:int, radius:float, node:Node2D):
	var points: PackedVector2Array = []
	# Add count points equidistant around a circle of radius radius
	for i: int in count:
		if count == 3:
			points.append(Vector2.from_angle(i*TAU/count - TAU/4)*radius)
		else:
			points.append(Vector2.from_angle(3*i*TAU/count - TAU/4)*radius)
			
	# Add first point again to form loop
	points.append(Vector2.from_angle(-TAU/4)*radius)
	# Draw line
	node.draw_polyline(points, colour, line_width)


func _draw() -> void:
	# Draw outline
	draw_circle(Vector2.ZERO, radius + radius_per_layer*8, colour, false, line_width)
