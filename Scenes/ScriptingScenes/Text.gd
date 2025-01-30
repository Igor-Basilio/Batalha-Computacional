extends TextEdit

onready var lua: Lua = Lua.new()
onready var ErrorLabel = get_parent().get_node("ErrorLabel")
onready var gd = $"/root/scene_handler/GameScene"

func _ready() -> void:
	ErrorLabel.text = ""
	highlight()
	define_game_builtins()
	
func luaCallBack(err):
	ErrorLabel.text = err
	 
## 
## Game builtins
##
	
func define_game_builtins():
	lua.expose_function(self, "place_tower",  "PlaceTower")
	lua.expose_function(self, "move_tower",   "MoveTower")
	lua.expose_function(self, "remove_tower", "RemoveTower")
	lua.expose_function(self, "get_tower_info", "GetTowerInfo")

func check_boundary(x, y) -> bool:
	## Maybe there's a better way instead of using magic numbers.
	if x > 19 or y > 10 or x < 0 or y < 0:
		 ErrorLabel.text = "Não é possível colocar a torre em (%d, %d)" % [x,  y]
		 return false
	return true

func get_tower_info(x, y) -> Array:
	 if not check_boundary(x, y):
		 return [null]
	 var tower = gd.GetTower(x, y)
	 return [ tower.type, 
		 GameData.tower_data[tower.type]["damage"],
		 GameData.tower_data[tower.type]["rof"],
		 GameData.tower_data[tower.type]["range"],
		 GameData.tower_data[tower.type]["category"] ]
	
func place_tower(type, x, y):
	
		match type:
			"Gun":
				pass
			"Missile":
				pass
			_:
				ErrorLabel.text = "Torre não existe"
				return

	 ## Check boundaries
	 if not check_boundary(x, y):
		 return
	 
	 if not gd.PlaceTower(type, x, y): ## if no errors were found then place the tower
		 ErrorLabel.text = "Local obstruído em (%d, %d)" % [x, y]
		 return
		
	 if gd.PurchaseTower(type): # Check if enough money to buy
		 ErrorLabel.text = "Dinheiro insuficiente (%d)" % gd.current_currency 
		 return
	
func remove_tower(x, y):
	pass
	
func move_tower(x, y, x1, y1):
	 pass
	
const keyword_color = Color(0.233582, 0.695313, 0.38148)
	
func highlight():
	add_keyword_color("and", keyword_color)
	add_keyword_color("break", keyword_color)
	add_keyword_color("do", keyword_color)
	add_keyword_color("else", keyword_color)
	add_keyword_color("elseif", keyword_color)
	add_keyword_color("end", keyword_color)
	add_keyword_color("false", keyword_color)
	add_keyword_color("for", keyword_color)
	add_keyword_color("function", keyword_color)
	add_keyword_color("if", keyword_color)
	add_keyword_color("in", keyword_color)
	add_keyword_color("local", keyword_color)
	add_keyword_color("nil", keyword_color)
	add_keyword_color("not", keyword_color)
	add_keyword_color("or", keyword_color)
	add_keyword_color("repeat", keyword_color)
	add_keyword_color("return", keyword_color)
	add_keyword_color("then", keyword_color)
	add_keyword_color("true", keyword_color)
	add_keyword_color("until", keyword_color)
	add_keyword_color("while", keyword_color)
	## Maybe add more keywords

func _on_RunButton_pressed():
	ErrorLabel.set_text("")
	lua.do_string(text, true, self, "luaCallBack")
