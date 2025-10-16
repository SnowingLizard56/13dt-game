class_name Enemy extends Node2D

const DAMAGE_LEEWAY: float = 1.0
const ENEMY_COLOUR: Color = Color(0.866667, 0.337255, 0.223529, 1.0)
const FLASH_COLOUR := Color.WHITE
const FLASH_TIME := 0.1

var current_colour:= ENEMY_COLOUR

@onready var hp: float = get_max_hp()
@onready var root: LevelController = Global.root

var body_id: int = -1

signal redraw
signal death

@export var death_particle_count: int = 0
@export var e127_proportion: float
@export var xp_value_range: Vector2
@export var e127_value_range: Vector2

var gen: EnemyGenerator


var x:
	get():
		if body_id < 0:
			return x
		return root.level.get_body(body_id).x + position.x
var y:
	get():
		if body_id < 0:
			return y
		return root.level.get_body(body_id).y + position.y
var vx:
	get():
		if body_id < 0:
			return vx
		return root.level.get_body(body_id).vx * Global.time_scale
var vy:
	get():
		if body_id < 0:
			return vy
		return root.level.get_body(body_id).vy * Global.time_scale


func _ready() -> void:
	if body_id >= 0:
		var body_dict: Dictionary = root.level.get_body(body_id)
		rotation = randf() * TAU
		position = Vector2.from_angle(rotation) * body_dict.r


func damage(amount: float) -> void:
	amount *= root.player.ship.get(&"All Damage").value
	amount *= GlobalOptions.get_damage_dealt_multiplier()
	
	if hp <= 0:
		return
	
	current_colour = FLASH_COLOUR
	redraw.emit()
	queue_redraw()
	await get_tree().create_timer(FLASH_TIME).timeout
	current_colour = ENEMY_COLOUR
	queue_redraw()
	redraw.emit()
	
	hp -= amount
	if hp <= DAMAGE_LEEWAY:
		death.emit()
		death_override()


func get_max_hp() -> float:
	# Necessary for getting MAX_HP in subclasses
	assert(&"MAX_HP" in self)
	return self.MAX_HP


func reparent_body(body: int):
	var old: Dictionary = root.level.get_body(body_id)
	rotation = Vector2(old.x, old.y).angle_to_point(Vector2(x, y))
	body_id = body
	var body_dict: Dictionary = root.level.get_body(body_id)
	position = Vector2.from_angle(rotation) * body_dict.r
	root.areas[body].add_child(self)


func death_override(): # Virtual # Why it no working D:
	# Exists to be overridden
	for i in death_particle_count:
		if randf() < e127_proportion:
			CollectParticle.new(
				CollectParticle.Types.E127,
				global_position,
				randf_range(e127_value_range.x, e127_value_range.y))
		else:
			CollectParticle.new(
				CollectParticle.Types.XP,
				global_position,
				randi_range(int(xp_value_range.x), int(xp_value_range.y)))
	queue_free()
