extends Node

const DEFAULT_SHIP: Ship = preload("res://Assets/ShipComponents/Base/base_ship.tres")
const MAIN_MENU_SCENE: PackedScene = preload("res://UI/main_menu.tscn")
const SHOP_SCENE: PackedScene = preload("res://Actors/Game/shop.tscn")
const MAP_SCENE: PackedScene = preload("res://map.tscn")
const GAME_FILE_PATH: String = "res://Actors/Game/game.tscn"
const PREDICTION_TIMESTEP: float = 5.0 / 8

@onready var game_scene: PackedScene = load(GAME_FILE_PATH)

@onready var player_ship: Ship = DEFAULT_SHIP.duplicate(true)

var time_scale: float = 4.8e5

var mouse_aim: Vector2 = Vector2.RIGHT
var joy_aim: Vector2 = Vector2.ZERO
var aim: Vector2 = Vector2.ZERO
var mouse_stale := false
var joy_stale := true
var level_seed: int = 1
var map: MapOwner

var root: Node = null
var map_scene: MapController

@onready var random: RandomNumberGenerator = RandomNumberGenerator.new()
var random_seed: int = randi()

signal frame_next
signal level_up


var player_currency: int = 0
var player_xp: float = 0.0
var player_level: int = 0
var tick

var using_controller = false


func _ready() -> void:
	if get_tree().current_scene is MapOwner:
		map = get_tree().current_scene
	else:
		root = get_tree().current_scene
	player_ship.set_components()


# Not my code. An algorithm essentially the same as Array.shuffle()
# Except it uses its own random number generator
func array_shuffle(array: Array) -> Array:
	# Each item except last two
	for i in len(array) - 2:
		# Swap it with a random index to the right
		var rand_idx = random.randi_range(i, len(array) - 1)
		var temp = array[rand_idx]
		array[rand_idx] = array[i]
		array[i] = temp
	return array


func _process(_delta: float) -> void:
	frame_next.emit()
	tick = Time.get_ticks_usec()
	
	# Get each device aim
	var new_mouse: Vector2 = (get_viewport().get_mouse_position() -\
		get_viewport().get_visible_rect().get_center()).normalized()
	if new_mouse == mouse_aim:
		mouse_stale = true
	else:
		mouse_aim = new_mouse
		mouse_stale = false
	
	var new_joy: Vector2 = Vector2(Input.get_axis("aim_left", "aim_right"), 
		Input.get_axis("aim_up", "aim_down")).normalized()
	if new_joy == joy_aim or new_joy == Vector2.ZERO:
		joy_stale = true
	else:
		joy_aim = new_joy
		joy_stale = false
	
	# Decide which to use
	if !joy_stale:
		aim = joy_aim
		using_controller = true
	elif joy_stale and !mouse_stale:
		aim = mouse_aim
		using_controller = false


func switch_scene(new_scene: PackedScene):
	var k: Node = new_scene.instantiate()
	if root == null and map:
		map.hide()
	else:
		root.queue_free()
	root = k
	get_tree().root.add_child(k)


func switch_to_map():
	var old: Node = root
	if not map:
		map = MAP_SCENE.instantiate()
		get_tree().root.add_child(map)
	else:
		map.reinit()
	root = null
	old.queue_free()


func reset():
	if map:
		map.queue_free()
		map = null
	player_ship = DEFAULT_SHIP.duplicate(true)
	player_currency = 0
	player_level = 0
	player_xp = 0
	switch_scene(game_scene)
