class_name Enemy extends Node2D

const DAMAGE_LEEWAY: float = 1.0
const ENEMY_COLOUR: Color = "dd5639"
@onready var hp: float = get_max_hp()


func damage(amount: float) -> void:
	hp -= amount
	if hp <= DAMAGE_LEEWAY:
		queue_free()


func get_max_hp() -> float:
	assert(&"MAX_HP" in self)
	return self.MAX_HP
