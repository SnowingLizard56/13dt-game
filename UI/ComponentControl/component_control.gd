class_name ComponentControl extends Control

const SHIP_SPRITE_RADIUS := 20.0
const PLAYER_COLOUR := Color(0.12549, 0.647059, 0.65098, 1)
const MANY_HULL_WARNING := "Ship has multiple hulls. Only the first is active.\n"
const NO_HULL_WARNING := "Ship has no hull.\n"
const MANY_THRUSTER_WARNING := "Ship has multiple thrusters. Only the first is active.\n"
const NO_THRUSTER_WARNING := "Ship has no thruster.\n"
const MANY_TRIGGER_WARNING := "Only the first four components with triggers are accessible.\n"
const NO_TRIGGER_WARNING := "Ship has no triggers.\n"
const SHIP_DESCRIPTION := "Hull Points: {3}\nMass: {0} T\nThrust: {1} kN\nAcceleration: {2} pxs⁻²"
const MAX_COMPONENTS := 7

@export var ship_display: Control
@export var component_scene: PackedScene

@export var ship_desc: Label
@export var warning_display: Control
@export var warning_label: Label
@export var cmpnt_title: Label
@export var cmpnt_desc: Label

@export var installed_count_label: Label
@export var spare_count_label: Label

@export var installed_components: VBoxContainer
@export var spare_components: VBoxContainer
@export var continue_button: CustomButton

@export var for_moving: Control

var working_ship: Ship

signal reprocessed
signal continue_pressed
signal swap_amount(value: int)

signal focused(what: ShipComponentNode, left: bool)


func _ready() -> void:
	continue_button.pressed.connect(continue_pressed.emit)


func _process(delta: float) -> void:
	ship_display.rotation -= delta


func draw_player():
	var sq_pts: PackedVector2Array = [
		Vector2(SHIP_SPRITE_RADIUS, SHIP_SPRITE_RADIUS),
		Vector2(-SHIP_SPRITE_RADIUS, SHIP_SPRITE_RADIUS),
		Vector2(-SHIP_SPRITE_RADIUS, -SHIP_SPRITE_RADIUS),
		Vector2(SHIP_SPRITE_RADIUS, -SHIP_SPRITE_RADIUS)
	]
	ship_display.draw_colored_polygon(sq_pts, PLAYER_COLOUR)


# Adds a component button to the scene and sets up signals
func add_component_option(what: ShipComponent, where: Node, allow_swap: bool = true):
	var k: ShipComponentNode = component_scene.instantiate()
	k.component = what
	where.add_child(k)
	k.focus_entered.connect(focused.emit.bind(k, where == installed_components))
	if allow_swap:
		if where == installed_components:
			k.pressed.connect(move_component_node.bind(k, spare_components))
			k.swap_cost = what.sell_value
		else:
			k.pressed.connect(move_component_node.bind(k, installed_components))
			k.swap_cost = what.buy_value


# Add all components from the given ship to the scene
func load_ship(ship: Ship, allow_swap: bool = true) -> void:
	for cmpnt in ship.components:
		add_component_option(cmpnt, installed_components, allow_swap)


# Recalculate and display the overall ship
func reprocess() -> void:
	working_ship.components = []
	for i in installed_components.get_children():
		working_ship.components.append(i.component)
	working_ship.set_components()
	
	warning_display.hide()
	warning_label.text = ""
	
	if working_ship.has_multiple_hulls:
		warning_label.text += MANY_HULL_WARNING
	if working_ship.no_hull:
		warning_label.text += NO_HULL_WARNING
	if working_ship.has_multiple_thrusters:
		warning_label.text += MANY_THRUSTER_WARNING
	if working_ship.no_thruster:
		warning_label.text += NO_THRUSTER_WARNING
	if working_ship.too_many_triggers:
		warning_label.text += MANY_TRIGGER_WARNING
	if working_ship.no_triggers:
		warning_label.text += NO_TRIGGER_WARNING
	
	if warning_label.text != "":
		warning_label.text = warning_label.text.rstrip("\n")
		warning_display.show()
	
	 # UI neighbours correction
	for i: Control in installed_components.get_children():
		i.focus_neighbor_bottom = ""
	if installed_components.get_child_count() > 0:
		warning_display.focus_neighbor_right = installed_components.get_child(0).get_path()
		installed_components.get_child(-1).focus_neighbor_bottom = continue_button.get_path()
	
	for i: Control in spare_components.get_children():
		i.focus_neighbor_bottom = ""
	if spare_components.get_child_count() > 0:
		spare_components.get_child(-1).focus_neighbor_bottom = continue_button.get_path()
	
	installed_count_label.text = str(installed_components.get_child_count()) + "/" + str(MAX_COMPONENTS)
	spare_count_label.text = str(spare_components.get_child_count()) + "/" + str(MAX_COMPONENTS)
	
	# Ship display
	ship_desc.text = SHIP_DESCRIPTION.format(round_to_dp([
		working_ship.mass,
		working_ship.thrust,
		working_ship.acceleration,
		working_ship.max_hp,
	], 2))
	
	reprocessed.emit()


# Handle hover of component button
func update_component_stat_display(c: ShipComponentNode, _left: bool):
	cmpnt_title.text = c.component.name
	cmpnt_desc.text = c.component.get_description()
	

# Handle the clicking of a component button
func move_component_node(node: ShipComponentNode, where: VBoxContainer):
	if where.get_child_count() == MAX_COMPONENTS:
		return
	node.reparent(where)
	for c in node.pressed.get_connections():
		node.pressed.disconnect(c.callable)
	
	for c in node.focus_entered.get_connections():
		node.focus_entered.disconnect(c.callable)
	
	node.focus_entered.connect(focused.emit.bind(node, where == installed_components))
	
	if where == installed_components:
		node.pressed.connect(move_component_node.bind(node, spare_components))
		swap_amount.emit(-node.swap_cost)
	else:
		node.pressed.connect(move_component_node.bind(node, installed_components))
		swap_amount.emit(node.swap_cost)
	node.grab_focus()
	reprocess()


func round_to_dp(data: Array, dp: int) -> Array:
	for i in len(data):
		data[i] = round(data[i] * 10 ** dp) / 10**dp
	return data


func start(available_components: Array[ShipComponent], ship_initial: Ship):
	working_ship = ship_initial
	load_ship(working_ship)
	reprocess()
	
	# Setup
	for i in len(available_components):
		add_component_option(available_components[i], spare_components)
	spare_components.get_child(0).grab_focus()


# Returns the unused components
func finish() -> Array[ShipComponent]:
	# Setdown
	var out: Array[ShipComponent] = []
	for n: ShipComponentNode in spare_components.get_children():
		out.append(n.component)
		n.queue_free()
	for n: ShipComponentNode in installed_components.get_children():
		n.queue_free()
	return out


func start_display_only(ship: Ship):
	working_ship = ship.duplicate(true)
	load_ship(working_ship, false)
	reprocess()
