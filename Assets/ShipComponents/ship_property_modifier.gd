class_name ShipPropertyModifier extends Resource

@export var property_name: StringName
@export var modify_amount: float
@export var modify_type: Types

enum Types {
	ADD,
	MULTIPLY
}
