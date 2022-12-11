extends Node

# Scene
var gamescene:PackedScene = preload("res://content/scenes/GameScene.tscn")

# Enviroment / Entities
var expiriance = "res://content/entities/Exp.tscn"
var vanishing_text = "res://content/entities/VanishText.tscn"
var VFX = "res://content/entities/VFX.tscn"
# Units
var unit = "res://content/units/Unit.tscn" # UNIT BASE LOAD FROM PULL AUTOMATICLY
var trasher = "res://content/units/Trasher.tscn"

# Unit Controllers
var unit_script = preload("res://scripts/units/Unit.gd")
var default_controller = preload("res://scripts/units/controllers/Controller.gd")
var enemy = preload("res://scripts/units/controllers/Enemy.gd")
var alien = preload("res://scripts/units/controllers/Alien.gd")
var player = preload("res://scripts/units/controllers/Player.gd")

# Cards
const card_holder = "res://content/ui/CardHolder.tscn" # Can be load from pull
const basic_card = preload("res://content/cards/basic-card.tres") # Used when create empty card for new Team

var cards_to_drop:Array = []
const all_cards = [] # Containes All loaded Cards

# Team
var team_alien = Color.orange
var team_enemy = Color.crimson

# Fx
var death_fx = "res://content/fx/Explosion.tscn"
var hit_fx = "res://content/fx/HitFx.tscn"

# Sounds / VFX
var unit_death_fx:Array = [
	preload("res://sounds/fx/Explosion-1.wav")
]
var card_select:AudioStream = preload("res://sounds/fx/Card-Select-1.wav")
var card_apply:AudioStream = preload("res://sounds/fx/Card-Apply.wav")
var level_up:AudioStream = preload("res://sounds/fx/Powerup.wav")

func reset_cards_out():
	cards_to_drop = all_cards.duplicate()

func drop_card() -> Card:
	var card = cards_to_drop[rand_range(0, len(cards_to_drop))]
	return card

func erase_card(card:Card):
	if not card.recursive:
		cards_to_drop.erase(card)

func _ready():
	# Loading All Cards
	var dir = Directory.new()
	dir.open("res://content/cards")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		print("File:",file)
		if file == "":
			break
		elif not file.begins_with("."):
			if file == "basic-card.tres":
				print("FUCK YOU")
			else:
				var path = "res://content/cards/" + file
				all_cards.append(load(path))
	dir.list_dir_end()
