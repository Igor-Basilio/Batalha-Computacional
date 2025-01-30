extends PathFollow2D

signal base_damage(damage)

var type

onready var speed = GameData.enemy_data[self.type]["speed"]
onready var hp = GameData.enemy_data[self.type]["hp"]
onready var base_damage = GameData.enemy_data[self.type]["base_damage"]

onready var game_scene  = $"/root/scene_handler/GameScene"
onready var health_bar  = get_node("HealthBar")
onready var impact_area = get_node("Impact")
var projectile_impact = preload("res://Scenes/SupportScenes/ProjectileImpact.tscn")

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	health_bar.set_as_toplevel(true)

func _physics_process(delta):
	if unit_offset == 1.0:
		emit_signal("base_damage", base_damage)
		queue_free()
	move(delta)
	
func move(delta):
	set_offset(get_offset() + speed * delta)
	health_bar.set_position(position - Vector2(30, 30))

func on_hit(damage):
	impact()
	hp -= damage
	health_bar.value = hp
	if hp <= 0:
		on_destroy()
		
func impact():
	var impact_pos = impact_area.get_position()
	randomize()
	var x_pos = randi() % int(2 * impact_pos.x + 1)
	randomize()
	var y_pos = randi() % int(2 * impact_pos.y + 1)
	var impact_location = Vector2(x_pos, y_pos)
	var new_impact = projectile_impact.instance()
	new_impact.position = impact_location
	impact_area.add_child(new_impact)
	
func on_destroy():
	get_node("KinematicBody2D").queue_free()
	yield(get_tree().create_timer(0.2), "timeout")
	self.queue_free()
	game_scene.on_enemy_destroyed(self.type)
