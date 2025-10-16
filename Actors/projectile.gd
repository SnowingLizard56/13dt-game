class_name Projectile extends Area2D

const COLOUR = Color.RED
const CULLING_DISTANCE: float = 2048
const FLYING_ENEMY_MASS: float = 5600
const RECOIL_TIME: float = 0.1
const PROJECTILE_DAMAGE_FACTOR: float = 0.5 * 0.0001

var x: float
var y: float
var vx: float
var vy: float
var source: Node2D
var source_e := Player.DeathSource.UNKNOWN
var root: LevelController
var mass: float
var is_enemy: bool
var trigger_particles: bool
var recoil_factor: float
var _dvx: float
var _dvy: float
var alive_time: float

var impact_hook: Array[Callable]

signal hit_body(id: int)


func _init(src: Node2D, dvx: float, dvy: float, shape: Shape2D, m: float = 1,
	cause_planet_particles: bool = false) -> void:
	hide()
	_dvx = dvx
	_dvy = dvy
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
	z_index = 1
	source = src
	if source is FlyingEnemy:
		source_e = Player.DeathSource.FLYING
	if source is CannonEnemy:
		source_e = Player.DeathSource.CANNON
	process_priority = source.process_priority - 1
	root = Global.root
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
	trigger_particles = cause_planet_particles
	# Recoil
	recoil_factor = 0.
	if src is FlyingEnemy:
		recoil_factor = -m / FLYING_ENEMY_MASS
	elif src is Player:
		recoil_factor = -m / (src.ship.mass * 1000)
	if recoil_factor != 0.0:
		var tween := get_tree().create_tween()
		tween.tween_method(apply_recoil, 0, RECOIL_TIME, RECOIL_TIME)


func _physics_process(delta: float) -> void:
	var grav: Dictionary = root.level.barnes_hut_probe(Global.time_scale, x, y, 1.4)
	alive_time += delta
	position = Vector2(x - root.player.x, y - root.player.y)
	vx += grav.ax * delta
	vy += grav.ay * delta
	x += vx * delta
	y += vy * delta
	if position.length_squared() > CULLING_DISTANCE ** 2:
		queue_free()
	show()


func _on_collision_area_entered(area: Area2D) -> void:
	var target: Node2D = area.get_parent()
	if area is Body:
		# Hit body. by bye
		hit_body.emit(area.get_meta("id"))
		if trigger_particles:
			area.crash_particles(area.position.angle_to_point(position))
		queue_free()
		return
	
	if target is Enemy and is_enemy:
		return
	if target is Player and not is_enemy:
		return
		
	if not is_enemy:
		for i in impact_hook:
			if area is Body:
				i.call(self, area)
			else:
				i.call(self, target)
	
	if target is Enemy:
		target.damage(calculate_damage(target))
		queue_free()
	if target is Player:
		target.damage(calculate_damage(target), source_e)
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
			draw_circle(i * pos, radius, COLOUR)
		draw_rect(
			Rect2(-pos - Vector2(0, radius), 2 * (pos + Vector2(0, radius))),
			COLOUR
		)


func calculate_damage(target: Node2D):
	var damage: float = Vector2(target.vx - vx, target.vy - vy).length_squared() * mass
	return damage * PROJECTILE_DAMAGE_FACTOR


func _ready() -> void:
	scale = Vector2.ZERO
	var tween := get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)


func apply_recoil(_t: float):
	var delta := get_process_delta_time()
	if source:
		var mult: float = recoil_factor * delta / RECOIL_TIME
		if source is Player:
			mult *= source.ship.get(&"Recoil").value
		source.vx += _dvx * mult
		source.vy += _dvy * mult
