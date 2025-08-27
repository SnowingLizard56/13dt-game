extends Node2D

const SIZE: Vector2i = Vector2i(7, 6)
const PATH_COUNT: int = 6
const SEPERATION: Vector2 = Vector2(120, -100.0)
const SHIMMY: float = 25.0
const ICON_SIZE: float = 0.38


func _ready() -> void:
	Global.random.seed = 1
	generate_map()


func generate_map():
	var map: Array[MapIcon]
	map.resize(SIZE.x * SIZE.y)
	for i in SIZE.x * SIZE.y:
		map[i] = MapIcon.new()
	
	# Prevent line cross
	var line_cross_left: Array[bool]
	line_cross_left.resize(SIZE.x * SIZE.y)
	line_cross_left.fill(false)
	var line_cross_right: Array[bool] = line_cross_left.duplicate()
	
	var node_count: int = 0
	
	# Iterate PATH_COUNT times
	for nth_path in PATH_COUNT:
		# Traverse a path
		var current: int
		var next: int
		current = Global.random.randi_range(1, SIZE.x - 2)
		map[current].in_map = true
		while current < map.size() - SIZE.x:
			# Clamp next within the bounds of the map
			var diff: int
			
			# Disallow left / right if already far left / right, or line cross
			var disallow_left = current % SIZE.x == 0 or line_cross_right[current - 1]
			var disallow_right = (current + 1) % SIZE.x == 0 or line_cross_left[current + 1]
			
			diff = Global.random.randi_range(-int(!disallow_left), int(!disallow_right))
			
			# Next index
			next = current + SIZE.x + diff
			# If its diagonal, there's potential for line crossing
			if diff == -1:
				line_cross_left[current] = true
			elif diff == 1:
				line_cross_right[current] = true
			
			# Update connections
			if not map[next] in map[current].connections:
				map[current].connections.append(map[next])
			
			if not map[next].in_map:
				node_count += 1
			
			map[next].in_map = true
			current = next
	
	# Generate node pool
	var pool: Array[Nebula] = Nebula.generate_pool(node_count)
	pool = Global.array_shuffle(pool)
	
	for i in len(map):
		# Add to tree if not there
		var map_node = map[i]
		if map_node.in_map:
			add_child(map_node)
			map_node.list_position = i
			map_node.map_position = Vector2(i % SIZE.x, i / SIZE.x)
			# First rank
			if map_node.map_position.y == 0:
				var allow: Array = [Nebula.UNCLAIMED]
				
				if !Global.is_xaragiln_friendly:
					allow.append(Nebula.XARAGILN)
				if !Global.is_namurant_friendly:
					allow.append(Nebula.NAMURANT)
				map_node.nebula = Nebula.new()
				while not map_node.nebula.type in allow:
					map_node.nebula = Nebula.new()
			else:
				# Take from pool
				map_node.nebula = pool.pop_back()
			# Position the node and offset it slightly
			map_node.position = map_node.map_position * SEPERATION + Vector2.ONE * SHIMMY * randf()
			map_node.scale *= ICON_SIZE
			# Sort connections by list_position
			map_node.connections.sort_custom(
				func (x: MapIcon, y: MapIcon): return x.list_position < y.list_position)
	
	queue_redraw()


func _draw():
	for icon: MapIcon in get_children():
		for next: MapIcon in icon.connections:
			# Make line	
			var direction: Vector2 = icon.position.direction_to(next.position)
			var start: Vector2 = icon.position + direction * 100 * ICON_SIZE
			var end: Vector2 = next.position - direction * 100 * ICON_SIZE
			draw_dashed_line(start, end, Color("f5e8d1"), 0.6, 2.0, true)
