extends Node

const SECTION := "WHY"
const DIFFICULTY_XP_SETTINGS: PackedFloat32Array = [
	40.0, 100.0, 400.0,
	70.0, 100.0, 700.0,
	100.0, 100.0, 1000.0,
	30.0, 20.0, 60.0,
	9999.0, 1.0, 9999.0]
const DIFFICULTY_DAMAGE_RECEIVED_MULTIPLIER = [
	0.333,
	0.5,
	0.8,
	1.0,
	2.0,
]
const DIFFICULTY_DAMAGE_DEALT_MULTIPLIER = [
	1.5,
	1.4,
	1.2,
	1.0,
	0.8,
]
enum Difficulty {
	CHALLENGING = 0,
	DIFFICULT = 1,
	HARD = 2,
	UNFORGIVING = 3,
	VERY_DIFFICULT = 4
}

var difficulty := Difficulty.CHALLENGING
var config := ConfigFile.new()
var err := config.load("user://opt.cfg")


func _ready() -> void:
	if err != OK:
		difficulty = config.get_value(SECTION, "difficulty", 2) as Difficulty


func spawn_enemies_mid() -> bool:
	return difficulty > Difficulty.HARD


func calculate_xp_cutoff() -> float:
	var minimum = DIFFICULTY_XP_SETTINGS[3 * difficulty as int]
	var point_x = DIFFICULTY_XP_SETTINGS[3 * difficulty as int + 1]
	var point_y = DIFFICULTY_XP_SETTINGS[3 * difficulty as int + 2]
	return (point_y - minimum) / point_x * Global.player_level + minimum


func get_damage_taken_multiplier() -> float:
	return DIFFICULTY_DAMAGE_RECEIVED_MULTIPLIER[difficulty as int]


func get_damage_dealt_multiplier() -> float:
	return DIFFICULTY_DAMAGE_DEALT_MULTIPLIER[difficulty as int]
