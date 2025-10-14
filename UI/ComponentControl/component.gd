class_name ShipComponentNode extends CustomButton

const TRIGGER_ICON_RADIUS: float = 20
var component: ShipComponent
var swap_cost: int


func _ready() -> void:
	text = " " + component.name
	if component is TriggerComponent:
		get_child(0).draw.connect(draw_trigger_icon)
	super()


func draw_trigger_icon():
	# In theory, this would separate components with triggers from
	# Components without triggers at a glance
	pass
