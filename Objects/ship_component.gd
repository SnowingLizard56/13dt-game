class_name ShipComponent extends Resource

@export var name: String
@export var mass: float
@export var damage_resistances: Dictionary[DamageTypes.Types, float]
var disabled: bool


func _installed(ship: Ship):
	pass
