class_name Ship extends Resource

signal took_damage(amnt: float)

@export var components: Array[ShipComponent] = []
@export var properties_base: Array[ShipProperty]
var trigger_components: Array[TriggerComponent] = []
signal components_updated

var base_thrust_profile: ThrustParticleProfile:
	set(v):
		base_thrust_profile = v
		thrust_profile_updated.emit(v)
var thrust_profile_override: ThrustParticleProfile:
	set(v):
		if v == null:
			thrust_profile_updated.emit(base_thrust_profile)
		else:
			thrust_profile_updated.emit(v)
		thrust_profile_override = v
signal thrust_profile_updated(new: ThrustParticleProfile)

# Warnings
var no_hull: bool
var has_multiple_hulls: bool
var no_thruster: bool
var has_multiple_thrusters: bool
var too_many_triggers: bool
var no_triggers: bool

# Stats
var thrust: float = 0
var mass: float = 0
var max_hp: float = 0

var acceleration: float = 0
var hp: float = 0
var misc_properties: Dictionary[StringName, ShipProperty] = {}

var thrust_modifier: float = 0:
	set(v):
		thrust_modifier = v
		acceleration = (thrust + thrust_modifier) / mass


func set_components(_components: Array[ShipComponent] = []) -> void:
	for i in components:
		i._uninstalled(self)
	var hp_ratio = hp / max_hp
	if max_hp == 0:
		hp_ratio = 1
	# Set
	if _components:
		components = _components
	
	# Reset
	thrust = 0
	mass = 0
	max_hp = 0
	no_hull = true
	no_thruster = true
	no_triggers = true
	has_multiple_hulls = false
	has_multiple_thrusters = false
	too_many_triggers = false
	trigger_components = []
	reset_misc_properties()
	
	# Iterate
	for cmpnt in components:
		mass += cmpnt.mass
		
		for p in cmpnt.misc_properties:
			misc_properties[p.property_name].modifiers.append(p)
		
		if cmpnt is ShipThruster:
			if !no_thruster:
				has_multiple_thrusters = true
			else:
				no_thruster = false
				thrust = max(thrust, cmpnt.thrust)
				base_thrust_profile = cmpnt.visual_profile
		elif cmpnt is ShipHull:
			if !no_hull:
				has_multiple_hulls = true
			no_hull = false
			max_hp = max(cmpnt.max_hp, max_hp)
		elif cmpnt is TriggerComponent:
			no_triggers = false
			if len(trigger_components) == 4:
				too_many_triggers = true
			else:
				trigger_components.append(cmpnt)
		
		cmpnt._installed(self)
	# Totals & Calculations
	acceleration = thrust / mass
	if is_nan(acceleration):
		acceleration = 0
	hp = max_hp * hp_ratio
	components_updated.emit()


func damage(amnt: float):
	hp -= amnt
	took_damage.emit(amnt)


func trigger(trigger_index: int, player: Player) -> void:
	assert(trigger_index < 4, str(trigger_index) + " is not a valid trigger index (>3)")
	if trigger_index < len(trigger_components):
		trigger_components[trigger_index]._trigger(player, self)


func reset_misc_properties():
	for p in properties_base:
		misc_properties[p.property_name] = p.duplicate(true)


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	for i in misc_properties:
		properties.append({
				"name": misc_properties[i].property_name,
				"type": TYPE_FLOAT,
			})
	return properties


func _get(property: StringName) -> Variant:
	if !misc_properties.has(property):
		return null
	return misc_properties[property]


func has_component(component_name: String) -> bool:
	for c in components:
		if c.name == component_name:
			return true
	return false
