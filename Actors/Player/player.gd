class_name Player extends Area2D

const SPRITE_RADIUS: int = 5
const DAMAGE_LEEWAY: float = 1.7
const MAX_ROTATION_SPEED: float = TAU * 0.5
const PLAYER_COLOUR := Color(0.12549, 0.647059, 0.65098, 1)
const FLASH_COLOUR := Color.WHITE
const DAMAGE_FLASH_TIME := 0.1

signal player_died

# Fun fact! floats are stored with double precision.
# However, floats that are part of Vector2s are single precision.
# Though it didnt end up being necessary for my uses... oh well.
var x: float = 750.0:
	get():
		if crashed:
			return level.get_body(crashed_body).x + crashed_offset.x
		else:
			return x
var y: float = 750.0:
	get():
		if crashed:
			return level.get_body(crashed_body).y + crashed_offset.y
		else:
			return y
var vx: float = 0.0
var vy: float = 0.0

var level: Level
var invincible: bool
var current_colour: Color = PLAYER_COLOUR
var invincibility_time: float = 0.5

var ship: Ship = null
@onready var ui: Control = %UI
@export var thrust: CPUParticles2D
@onready var thrust_current: CPUParticles2D = thrust
@onready var hitbox: Area2D = $Hitbox
@onready var invincibility_timeout: Timer = $InvincibilityTimeout
@onready var invincibility_flash: Timer = $InvincibilityFlash
@export var rotate_container: Node2D
@export var death_particles: CPUParticles2D

var trigger_queue: PackedInt32Array = []
var trigger_timer_queue: PackedFloat32Array = []

var is_dead: bool = false
var crashed: bool = false
var crashed_body: int
var crashed_offset: Vector2
var damage_hook: Array[Callable]

var death_source: DeathSource
enum DeathSource {
	PLANET = 0,
	UNKNOWN = 1,
	FLYING = 2,
	CANNON = 3,
	TENDRIL = 4,
}

@export var laser_scene: PackedScene

var flash_tween: Tween


func add_to_trigger_queue(id: int):
	if not id in trigger_queue:
		trigger_queue.append(id)
		if trigger_timer_queue:
			trigger_timer_queue.append(0.0)
		else:
			trigger_timer_queue.append(0.0)


func _ready() -> void:
	# This is so weird but it works whatever
	ship = Global.get(&"player_ship")
	ship.set_components()
	invincible = true
	ship.thrust_profile_updated.connect(_on_ship_thrust_profile_updated)


func _process(delta: float) -> void:
	if is_dead:
		return
	# Triggers
	if Input.is_action_pressed("trigger_1"):
		add_to_trigger_queue(0)
	if Input.is_action_pressed("trigger_2"):
		add_to_trigger_queue(1)
	if Input.is_action_pressed("trigger_3"):
		add_to_trigger_queue(2)
	if Input.is_action_pressed("trigger_4"):
		add_to_trigger_queue(3)
	
	if trigger_timer_queue:
		trigger_timer_queue[0] -= delta
		if trigger_timer_queue[0] <= 0.0:
			ship.trigger(trigger_queue[0], self)
			trigger_queue.remove_at(0)
			trigger_timer_queue.remove_at(0)


func _physics_process(delta: float) -> void:
	if is_dead:
		thrust.emitting = false
		if not crashed:
			grav_and_move(delta)
		return
	# Take input
	var acceleration_input = Vector2(
		Input.get_axis("player_left", "player_right"),
		Input.get_axis("player_up", "player_down")
	).normalized()
	# Visual
	if acceleration_input:
		if thrust.emitting:
			var diff: float = angle_difference(thrust.global_rotation, acceleration_input.angle())
			thrust.global_rotation += sign(diff) * min(abs(diff), MAX_ROTATION_SPEED * delta)
		else:
			thrust.global_rotation = acceleration_input.angle()
		thrust.emitting = true
	else:
		thrust.emitting = false
	
	var rotate_amount := -delta * ship.acceleration / 80
	rotate(rotate_amount)
	rotate_container.rotate(-rotate_amount)
	
	# Velocity then position
	vx += ship.acceleration * acceleration_input.x * delta
	vy += ship.acceleration * acceleration_input.y * delta
	
	if not level:
		level = get_parent().level
	
	grav_and_move(delta)


func grav_and_move(delta):
	var grav: Dictionary = level.barnes_hut_probe(Global.time_scale, x, y, 1.0, 0.0)
	vx += grav.ax * delta
	vy += grav.ay * delta
	
	x += vx * delta
	y += vy * delta


func _draw() -> void:
	if is_dead:
		return
	var sq_pts: PackedVector2Array = [
		Vector2(SPRITE_RADIUS, SPRITE_RADIUS),
		Vector2(-SPRITE_RADIUS, SPRITE_RADIUS),
		Vector2(-SPRITE_RADIUS, -SPRITE_RADIUS),
		Vector2(SPRITE_RADIUS, -SPRITE_RADIUS)
	]
	draw_colored_polygon(sq_pts, current_colour)


func _on_area_entered(area: Area2D) -> void:
	if area is Body:
		crashed = true
		crashed_body = area.id
		crashed_offset = -area.position
		if not is_dead:
			area.crash_particles(area.position.angle() + PI)
			ship.hp = 0.0
			ui.update_health(ship)
			death_source = DeathSource.PLANET
			generic_death()


func damage(amount: float, source: int = 1):
	if invincible and source != DeathSource.PLANET:
		return
	
	amount *= ship.get(&"Damage Taken").value
	amount += ship.get(&"Flat Damage Taken").value
	
	if amount <= 0.0:
		return
	
	for f in damage_hook:
		if f.call(amount, source):
			return
	
	flash(DAMAGE_FLASH_TIME)
	if ship.hp - amount <= DAMAGE_LEEWAY and ship.hp > 1:
		ship.hp = 1.0
	else:
		ship.hp -= amount
	ui.update_health(ship)
	if ship.hp <= 0:
		if not source:
			death_source = DeathSource.UNKNOWN
		else:
			death_source = source as DeathSource
		generic_death()
	invincible = true
	invincibility_timeout.start(invincibility_time)
	invincibility_flash.start()


func generic_death():
	is_dead = true
	player_died.emit()
	hitbox.get_child(0).set_deferred(&"disabled", true)
	if death_source != DeathSource.PLANET:
		death_particles.emitting = true
	queue_redraw()


func make_laser(weapon: LaserWeapon):
	var k: Laser = laser_scene.instantiate()
	k.weapon = weapon
	rotate_container.add_child(k)


func _on_invincibility_timeout_timeout() -> void:
	invincible = false
	invincibility_flash.stop()


func flash(time: float):
	if flash_tween:
		flash_tween.kill()
	
	flash_tween = get_tree().create_tween()
	flash_tween.tween_callback(func(): current_colour = FLASH_COLOUR)
	flash_tween.tween_callback(queue_redraw)
	flash_tween.tween_interval(time)
	flash_tween.tween_callback(func(): current_colour = PLAYER_COLOUR)
	flash_tween.tween_callback(queue_redraw)


func _on_ship_thrust_profile_updated(new: ThrustParticleProfile):
	if new == null:
		return
	thrust = new.apply(thrust)
