class_name Projectile extends Area2D

var x: float
var y: float
var vx: float
var vy: float
var source: Node2D
var root: LevelController 

signal hit_body(id: int)

func _init(src: Node2D, dvx: float, dvy: float, shape: Shape2D) -> void:
	x = src.x
	y = src.y
	vx = src.vx + dvx
	vy = src.vy + dvy
	source = src
	process_priority = source.process_priority + 1
	root = Global.get_tree().current_scene
	root.add_child(self)
	add_child(CollisionShape2D.new())
	get_child(0).shape = shape
	collision_layer = 8
	collision_mask = 7
	process_mode = Node.PROCESS_MODE_PAUSABLE
	area_entered.connect(_on_collision_area_entered)


func _physics_process(delta: float) -> void:
	var grav: Dictionary = root.level.barnes_hut_probe(delta * Global.time_scale ** 2, x, y, 1.4)
	vx += grav.ax
	vy += grav.ay
	x += vx * delta
	y += vy * delta
	position = Vector2(x - root.player.x, y - root.player.y)


func _on_collision_area_entered(area: Area2D) -> void:
	if area.collision_layer == 2:
		# Hit body. by bye
		hit_body.emit(area.get_meta("id"))
		queue_free()


func _draw() -> void:
	if get_child(0).shape is CircleShape2D:
		draw_circle(
			Vector2.ZERO,
			get_child(0).shape.radius,
			Color.WHITE
		)
