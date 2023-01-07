extends Node

# Scene
var gamescene:PackedScene = preload("res://content/scenes/GameScene.tscn")

# Enviroment / Entities
const energy = "res://content/entities/Energy.tscn"
const vanishing_text = "res://content/entities/VanishText.tscn"
const VFX = "res://content/entities/VFX.tscn"
const player_character = "res://content/entities/PlayerCharacter.tscn"
const background:PackedScene = preload("res://content/ui/ParallaxBackGround.tscn")
const path_spawner = preload("res://content/scenes/PathSpawner.tscn")
const path_map = preload("res://content/ui/PathMap.tscn")
# Units
const unit = "res://content/units/Unit.tscn" # UNIT BASE LOAD FROM PULL AUTOMATICLY
const trasher = "res://content/units/Trasher.tscn"
const sharp = "res://content/units/Sharp.tscn"
const main_ship_unit = "res://content/units/MainShip.tscn"
const path_sprite = "res://content/ui/PathSprite.tscn"
# Unit Controllers
const unit_script = preload("res://scripts/units/Unit.gd")
const default_controller = preload("res://scripts/units/controllers/Controller.gd")
const enemy = preload("res://scripts/units/controllers/Enemy.gd")
const alien = preload("res://scripts/units/controllers/Alien.gd")
const main_ship = preload("res://scripts/units/controllers/MainShip.gd")
const player = preload("res://scripts/units/controllers/Player.gd")

# Bullets
var basic_bullet = "res://content/units/bullets/Bullet.tscn"
var weak_bullet = "res://content/units/bullets/WeakBullet.tscn"

# Cards
const card_holder = "res://content/ui/CardHolder.tscn" # Can be load from pull
const basic_card = preload("res://content/cards/basic-card.tres") # Used when create empty card for new Team

var cards_to_drop:Array = []
const all_cards = [] # Containes All loaded Cards

# Shader Material
const hit_fx_material:Material = preload("res://content/shaders/HitShaderMat.tres")
const heal_shader_material:Material = preload("res://content/shaders/HealShaderMat.tres")

# Team
const team_alien = Color.orange
var team_enemy = Color.crimson # Because when We travel between planets we can find new Race's

# Fx
const death_fx = "res://content/fx/Explosion.tscn"
const hit_fx = "res://content/fx/HitFx.tscn"
const ride_fx = "res://content/fx/RideFx.tscn"
# Sounds / VFX
var unit_death_vfx:Array = [
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
		if file == "":
			break
		elif not file.begins_with("."):
			# Not Add Basic Card to Tree
			if not file == "basic-card.tres":
				var path = "res://content/cards/" + file
				all_cards.append(load(path))
	dir.list_dir_end()
