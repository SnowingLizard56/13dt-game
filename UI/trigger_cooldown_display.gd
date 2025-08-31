extends Control


const BG_COLOUR: Color = Color(0.059, 0.106, 0.149, 1.0)
const SOLID_COLOUR: Color = Color(0.961, 0.91, 0.82, 1.0)
const PLAYER_COLOUR: Color = Color(0.125, 0.647, 0.651, 1.0)
const ENEMY_COLOUR: Color = Color(0.867, 0.337, 0.224, 1.0)
const UNKNOWN_COLOUR: Color = Color(1.0, 0.937255, 0.631373, 1.0)

const HUD_BG_COLOUR: Color = Color(0.0941176, 0.168627, 0.239216, 1.0)
const HUD_CD_COLOUR: Color = Color(0.184314, 0.301961, 0.411765, 0.5)

@export var trigger_index := 0
@export var segment_count := 15
@export var radius := 11.0
@export var border := 5.0
@onready var root = Global.root

var component: TriggerComponent = null


func _ready() -> void:
	await Global.frame_next
	root.player.ship.components_updated.connect(link_component)
	link_component()


func _draw() -> void:
	if !component:
		hide()
		return
	show()
	draw_circle(size / 2, radius + border, HUD_BG_COLOUR)
	
	var pts: PackedVector2Array = [size / 2]
	var lim = TAU * component.get_time_left_ratio()
	
	if lim != 0:
		for i in segment_count + 1:
			var angle = i * TAU / segment_count
			
			if angle >= lim:
				pts.append(Vector2.from_angle(-lim - TAU / 4) * radius + size / 2)
				break
			else:
				pts.append(Vector2.from_angle(-angle - TAU / 4) * radius + size / 2)
		draw_colored_polygon(pts, HUD_CD_COLOUR)


func link_component():
	var tcomponents: Array[TriggerComponent] = root.player.ship.trigger_components
	if len(tcomponents) <= trigger_index:
		hide()
		return
	show()
	component = tcomponents[trigger_index]


func _process(delta: float) -> void:
	queue_redraw()
