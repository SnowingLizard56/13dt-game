class_name ShipProperty extends Resource

@export var property_name: StringName
@export var default_value: float

var modifiers: Array[ShipPropertyModifier] = []

var value:
	get():
		value = default_value
		for i in modifiers:
			match i.modify_type:
				ShipPropertyModifier.Types.ADD:
					value += i.modify_amount
				ShipPropertyModifier.Types.MULTIPLY:
					value *= i.modify_amount
		return value
