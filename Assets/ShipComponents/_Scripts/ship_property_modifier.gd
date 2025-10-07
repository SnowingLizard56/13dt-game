class_name ShipPropertyModifier extends Resource

@export var property: ShipProperty
@export var modify_amount: float
@export var modify_type: Types

var property_name:
	get():
		return property.property_name

enum Types {
	ADD,
	MULTIPLY
}
