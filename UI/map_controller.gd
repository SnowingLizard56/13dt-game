extends Node2D

const BUFFER_ROWS: int = 8
const WIDTH: int = 7
const PATH_COUNT: int = 6
const SEPARATION: Vector2 = Vector2(120, -125.0)
const SHIMMY: float = 12.5
const ICON_SIZE: float = 0.38
const START_INDENT: int = 1

var indices: PackedInt32Array = []
var map: Array[MapIcon]

var start: MapIcon


func _ready() -> void:
	indices.resize(PATH_COUNT)
	for i in PATH_COUNT:
		indices[i] = -1
	generate_map()


func generate_map():
	start = MapIcon.new()
	start.nebula = Nebula.new(Nebula.XARAGILN)
	start.scale *= ICON_SIZE
	add_child(start)
	# Ensure same map
	# IK THIS LOOKS USELESS
	# BUT IT AINT
	Global.random.seed = Global.random_seed
	
	for i in BUFFER_ROWS:
		_step()
	
	queue_redraw()


func _step():
	# Extend map
	map.resize(map.size() + WIDTH)
	for i in range(map.size() - WIDTH, map.size()):
		map[i] = MapIcon.new()
	
	# Init line crossing
	var line_cross_left: Array[bool]
	line_cross_left.resize(WIDTH)
	line_cross_left.fill(false)
	var line_cross_right: Array[bool] = line_cross_left.duplicate()
	
	# Shuffle line processing order
	var order = range(PATH_COUNT)
	order.shuffle()
	
	# Iterate
	for i in order:
		var current: int = indices[i]
		
		var map_current: MapIcon
		var map_next: MapIcon
		
		if indices[i] < 0:
			map_current = start
			indices[i] = randi_range(1, WIDTH - 2)
			map_next = map[indices[i]]
		else:
			# Disallow left / right if already far left / right, or line cross
			var disallow_left = current == 0 or line_cross_right[current - 1]
			var disallow_right = (current + 1) == WIDTH or line_cross_left[current + 1]
			
			var diff := Global.random.randi_range(-int(!disallow_left), int(!disallow_right))
			
			# Next index
			indices[i] += diff
			
			# If its diagonal, there's potential for line crossing
			if diff == -1:
				line_cross_left[current] = true
			elif diff == 1:
				line_cross_right[current] = true
			
			# Update connections
			map_current = map[map.size() - 2 * WIDTH + current]
			map_next = map[map.size() - WIDTH + indices[i]]
		
		if not map_next in map_current.connections:
			map_current.connections.append(map_next)
		
		map_next.in_map = true
	
	
	for i in range(map.size() - WIDTH, map.size()):
		# Add new to tree
		var map_node = map[i]
		# if theyre in-map
		if map_node.in_map:
			add_child(map_node)
			if map.size() > WIDTH:
				map_node.list_position = map[i - 1].list_position + 1
			else:
				map_node.list_position = i
			map_node.map_position = Vector2(i % WIDTH, i / WIDTH)
			# Position the node and offset it slightly
			map_node.position = (map_node.map_position + Vector2(0, 1)) * SEPARATION\
				+ Vector2.ONE * SHIMMY * randf()\
				+ Vector2.LEFT * SEPARATION * (WIDTH - 1.0) / 2
			map_node.scale *= ICON_SIZE
			# Sort connections by list_position
			map_node.connections.sort_custom(
				func (x: MapIcon, y: MapIcon): return x.list_position < y.list_position)
			map_node.nebula = Nebula.new()
	
	# If overbuffered. Remove first WIDTH elements.
	if map.size() / WIDTH > BUFFER_ROWS:
		for i in WIDTH:
			map[i].queue_free()
		map = map.slice(WIDTH)
	await Global.frame_next
	queue_redraw()


func _draw():
	for icon: MapIcon in get_children():
		for next: MapIcon in icon.connections:
			# Make line	
			var direction: Vector2 = icon.position.direction_to(next.position)
			var start: Vector2 = icon.position + direction * 100 * ICON_SIZE
			var end: Vector2 = next.position - direction * 100 * ICON_SIZE
			draw_dashed_line(start, end, Color("f5e8d1"), 0.6, 2.0, true)
