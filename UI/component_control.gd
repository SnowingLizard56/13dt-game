extends Control

const SHIP_SPRITE_RADIUS = 20
@onready var player: Player = %Player

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


func _process(delta: float) -> void:
	ship_display.rotation -= delta


func draw_player():
	var sq_pts: PackedVector2Array = [
		Vector2(SHIP_SPRITE_RADIUS, SHIP_SPRITE_RADIUS),
		Vector2(-SHIP_SPRITE_RADIUS, SHIP_SPRITE_RADIUS),
		Vector2(-SHIP_SPRITE_RADIUS, -SHIP_SPRITE_RADIUS),
		Vector2(SHIP_SPRITE_RADIUS, -SHIP_SPRITE_RADIUS)
	]
	ship_display.draw_colored_polygon(sq_pts, Color("20a5a6"))


# Adds a component button to the scene and setss up signals
func add_component_option(what: ShipComponent, where: Node):
	var k: ShipComponentNode = component_scene.instantiate()
	k.component = what
	where.add_child(k)
	k.focus_entered.connect(update_component_stat_display.bind(what))
	if where == installed_components:
		k.pressed.connect(move_component_node.bind(k, spare_components))
	else:
		k.pressed.connect(move_component_node.bind(k, installed_components))


# Add all components from the given ship to the scene
func load_ship(ship: Ship) -> void:
	for cmpnt in ship.components:
		add_component_option(cmpnt, installed_components)


# Recalculate and display the overall ship
func reprocess() -> void:
	player.ship.components = []
	for i in installed_components.get_children():
		player.ship.components.append(i.component)
	player.ship.set_components()
	
	warning_display.hide()
	warning_label.text = ""
	
	if player.ship.has_multiple_hulls:
		warning_label.text += "Ship has multiple hulls. Only the first is active.\n"
	if player.ship.no_hull:
		warning_label.text += "Ship has no hull.\n"
	if player.ship.has_multiple_thrusters:
		warning_label.text += "Ship has multiple thrusters. Only the first is active.\n"
	if player.ship.no_thruster:
		warning_label.text += "Ship has no thruster.\n"
	if player.ship.too_many_triggers:
		warning_label.text += "Only the first four components with triggers are accessible.\n"
	
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
	
	installed_count_label.text = str(installed_components.get_child_count()) + "/7"
	spare_count_label.text = str(spare_components.get_child_count()) + "/7"
	
	# Ship display
	ship_desc.text = \
	"""Hull Points: {3}
	Mass: {0} T
	Thrust: {1} kN
	Acceleration: {2} pxs⁻²""".format(round_to_dp([
		player.ship.mass,
		player.ship.thrust,
		player.ship.acceleration,
		player.ship.max_hp,
	], 2))


# Handle hover of component button
func update_component_stat_display(component: ShipComponent):
	cmpnt_title.text = component.name
	cmpnt_desc.text = component.get_description()
	

# Handle the clicking of a component button
func move_component_node(node: CustomButton, where: VBoxContainer):
	if where.get_child_count() == 7:
		return
	node.reparent(where)
	for c in node.pressed.get_connections():
		node.pressed.disconnect(c.callable)
	if where == installed_components:
		node.pressed.connect(move_component_node.bind(node, spare_components))
	else:
		node.pressed.connect(move_component_node.bind(node, installed_components))
	node.grab_focus()
	reprocess()


func round_to_dp(data: Array, dp: int) -> Array:
	for i in len(data):
		data[i] = round(data[i] * 10 ** dp) / 10**dp
	return data


func start(available_components: Array[ShipComponent]) -> Array[ShipComponent]:
	load_ship(player.ship)
	reprocess()
	
	# Setup
	for c in available_components:
		add_component_option(c, spare_components)
	
	# Wait
	get_tree().paused = true
	show()
	await continue_button.pressed
	get_tree().paused = false
	hide()
	
	# Setdown
	var out: Array[ShipComponent] = []
	for n: ShipComponentNode in spare_components.get_children():
		out.append(n.component)
	return out
