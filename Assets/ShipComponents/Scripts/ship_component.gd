class_name ShipComponent extends Resource

@export var name: String
@export_multiline var description: String = "--"
@export var mass: float
@export var sell_value: int
@export var misc_properties: Array[ShipPropertyModifier] = []


func _installed(_ship: Ship):
	pass


func _get_stat_string() -> String:
	return """Mass: {mass} T"""


func get_description() -> String:
	var out = _get_stat_string()
	for property in misc_properties:
		match property.modify_type:
			ShipPropertyModifier.Types.ADD:
				out += """
				{property_name}: +{modify_amount}""".format(property)
			ShipPropertyModifier.Types.MULTIPLY:
				out += """
				{property_name}: x{modify_amount}""".format(property)
	return (out + """
	{description}""").format(self)
