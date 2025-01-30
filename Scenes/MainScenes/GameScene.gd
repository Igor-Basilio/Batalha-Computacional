extends Node2D

## General 
onready var UI = get_node("UI")
onready var towers

## Player variables
signal game_finished(result)
var base_health  
var base_currency 
var current_currency

## Wave variables
var current_wave = 1
var enemies_in_wave = 0
var wave_in_progress = false
var last_wave
onready var wave_timer: Timer = $"WaveTimer"

## Build variables
onready var map_node   = self.get_child(0) # Keep >> [ Map is always first child of GameScene ]
var build_mode = false
var build_valid = false
var build_location 
var build_tile 
var build_type
var obstructed_tile_num

##
## Purchase functions
##

## Returns true if not enough money to purchase a tower
## false otherwise.

func PurchaseTower(type) -> bool:
	match type:
		"Gun":
			if current_currency < 20:
				return true
			else:
				current_currency -= 20
		"Missile":
			if current_currency < 50:
				return true
			else:
				current_currency -= 50
	
	UI.update_currency(current_currency)
	return false
	
func PlaceTower(type, x, y):
	build_type = type + "T1"
	
	if map_node.get_node("TowerExclusion").get_cell(x, y) == TileMap.INVALID_CELL:
		map_node.get_node("TowerExclusion").set_cell(x, y, obstructed_tile_num)
		var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
		new_tower.position = map_node.get_node("TowerExclusion").map_to_world(Vector2(x, y))
		new_tower.built    = true
		new_tower.type     = build_type
		new_tower.category = GameData.tower_data[build_type]["category"]
		map_node.get_node("Towers").add_child(new_tower, true)
	else:
		 return false
		
	## Return true if tower was sucessfully placed
	return true
	
func GetTower(x, y):
	if map_node.get_node("TowerExclusion").get_cell(x, y) == obstructed_tile_num:
		var tower_pos = map_node.get_node("TowerExclusion").map_to_world(Vector2(x,y))
		for t in towers.get_children():
			if t.position == tower_pos:
				return t
		return null
	else:
		return null
	
##
## Common functions
##

func _ready():
	
	last_wave = GameData.map_wave_data[map_node.get_name()]["last_wave"]
	base_currency = GameData.map_data[map_node.get_name()]["base_currency"]
	base_health   = GameData.map_data[map_node.get_name()]["base_hp"]
	current_currency = base_currency
	towers = map_node.get_node("Towers")
	
	match map_node.get_name():
		"Map1":
			obstructed_tile_num = 6
		"Map2":
			obstructed_tile_num = 14
	
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.connect("pressed", self, "initiate_build_mode", [i.get_name()]) 
		
	wave_timer.connect("timeout", self, "_on_wave_timer", [], CONNECT_ONESHOT)	
			
func _process(delta):
	if build_mode:
		update_tower_preview()
	elif wave_in_progress:
		wave_in_progressf()
	
func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
		
##
## Wave functions
##

func on_enemy_destroyed(type):
	 enemies_in_wave  -= 1
	
	 match type:
		 "BlueTank":
			 current_currency += 10
			
	 get_node("UI").update_currency(current_currency)

func wave_in_progressf():
	
	# Preemptively start the waves
	#if enemies_in_wave == 0:
	#	wave_timer.stop()
	#	start_next_wave()
	
	if current_wave == last_wave + 1 and enemies_in_wave == 0:
		emit_signal("game_finished", true)
		wave_in_progress = false
		Engine.set_time_scale(1.0)

func start_next_wave():
	
	if current_wave == last_wave + 1:
		return
		
	wave_in_progress = true
	var wave_data_and_time = retrieve_wave_data()
	spawn_enemies(wave_data_and_time[0])
	
	## Before the game had continuous waves. 
	#wave_timer.stop()
	#wave_timer.start(wave_data_and_time[1])
	
func _on_wave_timer():
	start_next_wave()
	
func retrieve_wave_data():
	var time_for_next_wave = GameData.map_wave_data[map_node.get_name()]["wave" + str(current_wave)][1]
	var wave_data = GameData.map_wave_data[map_node.get_name()]["wave" + str(current_wave)][0]
	current_wave += 1
	enemies_in_wave += wave_data.size()
	return [wave_data, time_for_next_wave]
	
func spawn_enemies(wave_data):
	for i in wave_data:
		var new_enemy = load("res://Scenes/Enemies/" + i[0] + ".tscn").instance()
		new_enemy.connect("base_damage", self, "on_base_damage")
		new_enemy.type = i[0]
		map_node.get_node("Path").add_child(new_enemy, true)
		yield(get_tree().create_timer(i[1]), "timeout")
	
func on_base_damage(damage):
	base_health -= damage
	enemies_in_wave -= 1
	if base_health <= 0:
		emit_signal("game_finished", false)
	else:
		get_node("UI").update_health_bar(base_health)
	
##
## Building functions
##

func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	build_type = tower_type + "T1"
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())
	
func update_tower_preview():
	var mouse_pos = get_global_mouse_position()
	var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_pos)
	var tile_pos = map_node.get_node("TowerExclusion").map_to_world(current_tile)
	
	## If there is no valid cell on the spot we are trying to build.
	## seems weird but is how it should work.
	if map_node.get_node("TowerExclusion").get_cellv(current_tile) == TileMap.INVALID_CELL:		
		get_node("UI").update_tower_preview(tile_pos, "ad54ff3c")
		build_valid = true
		build_location = tile_pos
		build_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_pos, "adff4545")
		build_valid = false
	
func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").free()
	
func verify_and_build():
	if build_valid:
		var new_tower = load("res://Scenes/Turrets/" + build_type + ".tscn").instance()
		new_tower.position = build_location
		new_tower.built    = true
		new_tower.type     = build_type
		new_tower.category = GameData.tower_data[build_type]["category"]
		map_node.get_node("Towers").add_child(new_tower, true)
		map_node.get_node("TowerExclusion").set_cellv(build_tile, obstructed_tile_num)
		cancel_build_mode()
