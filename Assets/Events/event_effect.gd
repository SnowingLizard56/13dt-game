class_name EventEffect extends Resource

@export var title: String
@export var description: String
@export_category("Health")
## Proportion of max health gained or lost between -1 and 1.
@export var health_prop: float = 0.0
## Flat health gained or lost.
@export var health_change: float = 0.0
@export_category("E127")
## Change in e127. Can be negative.
@export var money: int = 0
@export_category("ShipComponents")
## Components that will always be offered to player
@export var component_list: Array[ShipComponent] = []
## Table to be rolled on a number of times to offer ShipComponents to player
@export var component_table: LootTable
## Number of times to roll on table
@export var table_roll_count: int = 0
@export_category("Random Effects")
@export var effects: Array[EventEffect] = []
@export var weights: Array[float] = []
@export_category("Next Event")
@export var next_event: MapEvent = null


func apply(map_ui: MapUI, ship: Ship) -> MapEvent:
	var next_event: MapEvent = next_event
	# Health
	ship.hp += ship.max_hp * health_prop
	ship.hp += health_change
	if ship.hp <= 0:
		ship.hp = 1.0
	elif ship.hp > ship.max_hp:
		ship.hp = ship.max_hp
	
	# E127
	map_ui.change_currency(money)
	
	# ShipComponents
	map_ui
	
	# EventEffects
	var other_event = effects[Global.random.rand_weighted(weights)].apply(map_ui, ship)
	if other_event:
		next_event = other_event
	return next_event
