class_name ShipComponentNode extends CustomButton

var component: ShipComponent
const TRIGGER_ICON_RADIUS: float = 20


func _ready() -> void:
	assert(component != null)
	text = " " + component.name
	if component is TriggerComponent:
		get_child(0).draw.connect(draw_trigger_icon)
	super()
	assert(size.x == custom_minimum_size.x, "'" + component.name + "' is too long.")


func draw_trigger_icon():
	#draw_circle()
	pass
