extends Node2D

@export var colour: = Color.WHITE
@export var count : Array[int] = [2,7,19,31,37,17,11,3]
@export var first_radius : int = 8
@export var radius_per_layer : int = 10

func _ready() -> void:
	for i in 8:
		# Instantiate
		var node:Node2D = Node2D.new()
		add_child(node, false, Node.INTERNAL_MODE_FRONT)
		# Connect draw to bound function
		node.draw.connect(draw_dot_layer.bind(count[i], first_radius+radius_per_layer*i, node))
		# Set random rotation
		node.rotation = randf_range(0, TAU)


func _process(delta: float) -> void:
	# Rotate children
	for i in get_child_count(true):
		get_child(i, true).rotate(2*delta/(i+2))


func draw_dot_layer(num:int, distance:float, node:Node2D):
	# Draw circles spaced equally around a circle
	for i in num:
		node.draw_circle(Vector2.from_angle(i*TAU/num - TAU/4)*distance, 2, colour)


func _draw() -> void:
	# Draw outline
	draw_circle(Vector2.ZERO, first_radius + 8*radius_per_layer, colour, false)
