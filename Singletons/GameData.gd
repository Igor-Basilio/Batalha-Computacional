extends Node

var enemy_data = {
	
	"BlueTank": 
	{
		"speed": 150,
		"hp":    50,
		"base_damage": 21,
	},
	
	"TankRedB":
	{
		"speed": 75,
		"hp":    250,
		"base_damage": 60,
	}
	
}

var tower_data = {
	
	"GunT1":
	{ 
	  "damage": 20,
	  "rof": 1,
	  "range": 350,
	  "category": "Projectile"
	},
	
	"MissileT1":
	{
		"damage": 100,
		"rof": 3,
		"range": 550,
		"category": "Missile"
	},
	
	"GunT2":
	{
		"damage": 100,
		"rof": 3,
		"range": 550,
		"category": "Projectile"
	},
	
	"GunT3":
	{
		"damage": 100,
		"rof": 3,
		"range": 550,
		"category": "Projectile"
	}
	
}

var map_data = {
	
	"Map1": 
	{
		"base_currency": 100,
		"base_hp":       100,
	},
	
	"Map2":
	{
		
	},
	
}

## 
##   [ [ [EnemyName, time_for_next_enemy], ... ], time for next wave ] 
##

var map_wave_data = {
	
	"Map1": 
	{
		"wave1": [[["BlueTank", 0.7], ["BlueTank", 0.1]], 12],
		"wave2": [[["BlueTank", 0.7], ["TankRedB", 0.1], ["BlueTank", 0.3], ["BlueTank", 0.1]], 15],
		"wave3": 
		[[ ["BlueTank", 0.7], ["BlueTank", 0.1], ["BlueTank", 0.3], ["BlueTank", 0.1],
		  ["BlueTank", 0.7], ["BlueTank", 0.1], ["BlueTank", 0.3], ["BlueTank", 0.1]	
			
		], 9],
		"last_wave": 3,
	},
	
	"Map2": 
	{
		"wave1": [[["BlueTank", 0.7], ["BlueTank", 0.1]], 3.5],
		"wave2": [[["BlueTank", 0.7], ["BlueTank", 0.1], ["BlueTank", 0.3], ["BlueTank", 0.1]], 4],
		"wave3": 
		[[ ["BlueTank", 0.7], ["BlueTank", 0.1], ["BlueTank", 0.3], ["BlueTank", 0.1],
		  ["BlueTank", 0.7], ["BlueTank", 0.1], ["BlueTank", 0.3], ["BlueTank", 0.1]	
			
		], 4],
		"last_wave": 3,
	},
	
}
