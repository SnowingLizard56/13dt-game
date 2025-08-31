class_name Enemy extends Node2D

const DAMAGE_LEEWAY: float = 1.0
const ENEMY_COLOUR: Color = "dd5639"
const FLASH_COLOUR := Color.WHITE

var current_colour:= ENEMY_COLOUR

@onready var hp: float = get_max_hp()
@onready var root: LevelController = Global.root

var body_id: int = -1

signal redraw

@export var death_particle_count: int = 0
@export var e127_proportion: float
@export var xp_value_range: Vector2
@export var e127_value_range: Vector2


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


func damage(amount: float) -> void:
	amount *= root.player.ship.get(&"All Damage").value
	
	if hp < 0:
		return
	hp -= amount
	if hp <= DAMAGE_LEEWAY:
		queue_free()
		
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
	else:
		current_colour = FLASH_COLOUR
		redraw.emit()
		queue_redraw()
		await get_tree().create_timer(0.1).timeout
		current_colour = ENEMY_COLOUR
		queue_redraw()
		redraw.emit()


func get_max_hp() -> float:
	assert(&"MAX_HP" in self)
	return self.MAX_HP

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		# Increment
		root.enemy_gen.total_enemies_alive += 1
	elif what == NOTIFICATION_PREDELETE:
		# Decrement
		root.enemy_gen.total_enemies_alive -= 1
		
