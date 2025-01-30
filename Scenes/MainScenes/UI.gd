extends CanvasLayer

onready var scene_handler = $"/root/scene_handler"
onready var hp_bar = get_node("HUD/TopBar/InfoBar/H/HP")
onready var hp_bar_tween = get_node("HUD/TopBar/InfoBar/H/HP/Tween")
onready var play_button = get_node("HUD/GameControlButtons/MarginContainer/HBoxContainer/PlayButton")
var start_wave = false

##
## Godot builtins
##

func _process(delta):
	if get_parent().enemies_in_wave == 0:
		play_button.self_modulate = Color(0.36, 0.58, 0.95)
		play_button.set_pressed_no_signal(false)
		start_wave = true	
		get_tree().paused = false

##
## Game state functions
##

func update_currency(current_currency):
	 get_node("HUD/TopBar/InfoBar/H/Money").text = str(current_currency)

func update_health_bar(base_health):
	hp_bar_tween.interpolate_property(hp_bar, 'value', hp_bar.value, base_health, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	hp_bar_tween.start()
	if base_health >= 60:
		hp_bar.set_tint_progress("4eff15")
	elif base_health <= 60 and base_health >= 25:
		hp_bar.set_tint_progress("e1be32")
	else:
		hp_bar.set_tint_progress("e11e1e")

func on_win_screen():
	scene_handler.get_node("GameScene/UI").visible = false
	var win_scene = load("res://Scenes/UIScenes/win_scene.tscn").instance()
	scene_handler.add_child(win_scene)
	scene_handler.move_child(scene_handler.get_node("win_scene"), 0)

##
## Tower preview functions
##

func set_tower_preview(tower_type, mouse_pos):
	var drag_tower = load("res://Scenes/Turrets/" + tower_type + ".tscn").instance()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("ad54ff3c")

	var range_texture = Sprite.new()
	range_texture.position = Vector2(32, 32)
	var scaling = GameData.tower_data[tower_type]["range"] / 600.0
	range_texture.scale = Vector2(scaling, scaling)
	var texture = load("res://Assets/UI/range_overlay.png")
	range_texture.texture = texture
	range_texture.modulate = Color("ad54ff3c")

	var control = Control.new()
	control.add_child(drag_tower, true)
	control.add_child(range_texture, true)
	control.rect_position = mouse_pos
	control.set_name("TowerPreview")
	add_child(control, true)
	move_child(get_node("TowerPreview"), 0)

func update_tower_preview(new_pos, color):
	get_node("TowerPreview").rect_position = new_pos
	if get_node("TowerPreview/DragTower").modulate != Color(color):
		get_node("TowerPreview/DragTower").modulate = Color(color)
		get_node("TowerPreview/Sprite").modulate = Color(color)
		
##
## Game control functions
##

func _on_PlayButton_pressed():
	if get_tree().is_paused():
		get_tree().paused = false
	elif start_wave:
		start_wave = false
		play_button.self_modulate = Color(1, 1, 1)
		get_parent().start_next_wave()	
		get_tree().paused = false
	else:
		get_tree().paused = true
		
func _on_FFButton_pressed():
	if Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(1.0)
	else:
		Engine.set_time_scale(2.0)
