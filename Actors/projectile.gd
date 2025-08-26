class_name Projectile extends Area2D

const COLOUR = Color.RED
const CULLING_DISTANCE: float = 4096

var x: float
var y: float
var vx: float
var vy: float
var source: Node2D
var root: LevelController 
var mass: float
var is_enemy: bool

signal hit_body(id: int)


func _init(src: Node2D, dvx: float, dvy: float, shape: Shape2D, m: float = 1) -> void:
	hide()
	vx = src.vx + dvx
	vy = src.vy + dvy
	var spawn_distance := Vector2(dvx, dvy).normalized()
	if shape is CircleShape2D:
		spawn_distance *= shape.radius
	elif shape is CapsuleShape2D:
		spawn_distance *= shape.height / 2
	else:
		spawn_distance = Vector2(dvx, dvy) * 0.1
	x = src.x + spawn_distance.x
	y = src.y + spawn_distance.y
	source = src
	process_priority = source.process_priority - 1
	root = Global.get_tree().current_scene
	root.entities.add_child(self)
	add_child(CollisionShape2D.new())
	get_child(0).shape = shape
	collision_layer = 8
	collision_mask = 7
	process_mode = Node.PROCESS_MODE_PAUSABLE
	area_entered.connect(_on_collision_area_entered)
	if shape is CapsuleShape2D:
		get_child(0).rotation = TAU / 4
	rotation = Vector2(dvx, dvy).angle()
	position = Vector2(x - root.player.x, y - root.player.y)
	mass = m
	is_enemy = src is Enemy


func _physics_process(delta: float) -> void:
	var grav: Dictionary = root.level.barnes_hut_probe(Global.time_scale, x, y, 1.4)
	position = Vector2(x - root.player.x, y - root.player.y)
	vx += grav.ax * delta
	vy += grav.ay * delta
	x += vx * delta
	y += vy * delta
	if position.length_squared() > CULLING_DISTANCE ** 2:
		queue_free()
	show()


func _on_collision_area_entered(area: Area2D) -> void:
	if area is Body:
		# Hit body. by bye
		hit_body.emit(area.get_meta("id"))
		queue_free()
		return
	var target: Node2D = area.get_parent()
	if target is Enemy and is_enemy:
		return
	if target is Player and not is_enemy:
		return	
	target.damage(calculate_damage(target))
	queue_free()


func _draw() -> void:
	if get_child(0).shape is CircleShape2D:
		draw_circle(
			Vector2.ZERO,
			get_child(0).shape.radius,
			COLOUR
		)
	elif get_child(0).shape is RectangleShape2D:
		var rect_size: Vector2 = get_child(0).shape.size
		draw_rect(
			Rect2(-rect_size / 2, rect_size),
			COLOUR
		)
	elif get_child(0).shape is CapsuleShape2D:
		var height: float = get_child(0).shape.height
		var radius: float = get_child(0).shape.radius
		var pos: Vector2 = Vector2(height / 2 - radius, 0)
		for i in [-1, 1]:
			draw_circle(i*pos, radius, COLOUR)
		draw_rect(
			Rect2(-pos - Vector2(0, radius), 2 * (pos + Vector2(0, radius))),
			COLOUR
		)


func calculate_damage(target: Node2D):
	return Vector2(target.vx - vx, target.vy - vy).length_squared() ** 0.25 * mass
