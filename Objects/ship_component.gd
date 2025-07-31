class_name ShipComponent extends Resource

@export var name: String
@export_multiline var description: String = "--"
@export var mass: float


func _installed(ship: Ship):
	pass


func _get_stat_string() -> String:
	return """Mass: {mass} T"""


func get_description() -> String:
	return (_get_stat_string() + """
	{description}""").format(self)
