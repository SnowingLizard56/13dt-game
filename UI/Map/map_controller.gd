class_name MapController extends Node2D

const STAR_COLOUR: Color = Color(0.960784, 0.909804, 0.819608, 1)
const BUFFER_ROWS: int = 10
const INITIAL_BUFFER: int = 6
const WIDTH: int = 8
const PATH_COUNT: int = 7
const SEPARATION: Vector2 = Vector2(120, -125.0)
const SHIMMY: float = 10
const ICON_SIZE: float = 0.38
const START_INDENT: int = 2
const POOL_SIZE: int = 12
const STAR_COUNT: int = 2304

var indices: PackedInt32Array = []
var map: Array[MapIcon]

var map_start: MapIcon
var rows_travelled: int = 0
var at_row: int = 0
var pool: Array[Nebula]
@onready var pool_idx: int = POOL_SIZE

@export var theme: Theme
@export var background: ColorRect
@export var position_indi: Node2D
@export var cam: Camera2D

var player_icon: MapIcon
var focused_icon: MapIcon

signal any_icon_pressed


func _ready() -> void:
	indices.resize(PATH_COUNT)
	for i in PATH_COUNT:
		indices[i] = -1
	generate_map()
	await Global.frame_next
	player_icon = map_start
	focus_connections(map_start)


func take_step():
	at_row += 1
	_step()
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", position - Vector2(0, SEPARATION.y), 1.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_redraw)
	player_icon = focused_icon
	focused_icon = null
	position_indi.move_to(player_icon)


func generate_map(_state = null):
	map_start = MapIcon.new()
	map_start.nebula = Nebula.new(Nebula.XARAGILN)
	map_start.scale *= ICON_SIZE
	map_start.in_map = true
	map_start.focus_mode = Control.FOCUS_NONE
	add_child(map_start)
	position_indi.move_to(map_start)
	# Ensure same map
	# IK THIS LOOKS USELESS
	# BUT IT AINT
	Global.random.seed = Global.random_seed
	
	for i in INITIAL_BUFFER:
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
			map_current = map_start
			indices[i] = randi_range(START_INDENT, WIDTH - 1 - START_INDENT)
			map_next = map[indices[i]]
		else:
			# Disallow left / right if already far left / right, or line cross
			var disallow_left = current == 0 or line_cross_right[current - 1]
			var disallow_right = (current + 1) == WIDTH or line_cross_left[current + 1]
			
			var diff: int = Global.random.randi_range(-int(not disallow_left), int(not disallow_right))
			
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
		
		# Apply nebulae for
		if pool_idx == POOL_SIZE:
			pool_idx = 0
			pool = Global.array_shuffle(Nebula.generate_pool(POOL_SIZE))
		if rows_travelled % 5 == 3:
			# Really hard to tell if this is working tbh.
			map_next.nebula = Nebula.new(Nebula.XARAGILN)
		else:
			map_next.nebula = pool[pool_idx]
			pool_idx += 1
			
			# Ensure that choices are actually choices
			if len(map_current.connections) > 1:
				ensure_choice(map_current)
			
	
	var last_node: MapIcon = null
	for i in WIDTH:
		# Add new to tree
		var map_node = map[map.size() - WIDTH + i]
		# If theyre in the map...
		if map_node.in_map:
			map_node.list_position = i + WIDTH * rows_travelled
			map_node.map_position = Vector2(i, rows_travelled)
			# Position the node and offset it slightly
			map_node.position = (map_node.map_position + Vector2(0, 1)) * SEPARATION\
				+ SHIMMY * Vector2(randf_range(-1, 1), randf_range(-1, 1))\
				+ Vector2.LEFT * SEPARATION * (WIDTH - 1.0) / 2
			map_node.scale *= ICON_SIZE
			add_child(map_node)
			if last_node:
				last_node.focus_neighbor_right = map_node.get_path()
				map_node.focus_neighbor_left = last_node.get_path()
			last_node = map_node
	
	# If overbuffered. Remove first WIDTH elements.
	if map.size() / WIDTH as int > BUFFER_ROWS:
		if map_start:
			map_start.queue_free()
		for i in WIDTH:
			map[i].queue_free()
		map = map.slice(WIDTH)
	rows_travelled += 1


func _draw():
	for icon in get_children():
		if not icon is MapIcon or icon.is_queued_for_deletion() or not icon.in_map:
			continue
		for next: MapIcon in icon.connections:
			if not next:
				continue
			# Make line
			var p1 = icon.position + icon.size * icon.SCALE_NORMAL / 2
			var p2 = next.position + next.size * icon.SCALE_NORMAL / 2
			var direction: Vector2 = p1.direction_to(p2)
			var start: Vector2 = p1 + direction * 100 * ICON_SIZE
			var end: Vector2 = p2 - direction * 100 * ICON_SIZE
			draw_dashed_line(start, end, Color("f5e8d1"), 1, 2.0, true)


func focus_connections(source: MapIcon):
	for i in map:
		i.focus_mode = Control.FOCUS_NONE
	
	var min_distance: float = INF
	var mouse_position: Vector2 = get_local_mouse_position()
	for icon in source.connections:
		if icon.in_map:
			icon.focus_mode = Control.FOCUS_ALL
			var d: float = mouse_position.distance_squared_to(icon.position)
			if d < min_distance:
				icon.grab_focus()
				min_distance = d


func _on_background_draw() -> void:
	for i in STAR_COUNT:
		background.draw_circle(
			background.size * Vector2(randf_range(-1, 2), randf_range(-1, 2)),
			.5,
			STAR_COLOUR,
		)


func icon_focused(icon: MapIcon):
	focused_icon = icon


func icon_pressed(icon: MapIcon):
	if icon != focused_icon:
		return
	any_icon_pressed.emit()


func icon_confirmed():
	if focused_icon:
		take_step()
		focused_icon.release_focus()
		focused_icon = null


func grab_focus(force: bool = false):
	if focused_icon:
		var current = focused_icon
		focus_connections(player_icon)
		current.grab_focus()
	elif force:
		focus_connections(player_icon)


func release_focus():
	for i in player_icon.connections:
		i.focus_mode = Control.FOCUS_NONE
		i.release_focus()


func ensure_choice(icon: MapIcon):
	while icon.connections[0].nebula.type == icon.connections[1].nebula.type:
		icon.connections[randi_range(0, len(icon.connections) - 1)].nebula = Nebula.new()
