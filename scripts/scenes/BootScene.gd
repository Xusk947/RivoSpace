extends Node2D
class_name BootScene

const UNIT_LOAD_AMOUNT:int = 30
const ENTITIES_LOAD_AMOUNT:int = 30
const FX_LOAD_AMOUNT:int = 50
const BULLETS_LOAD_AMOUNT:int = 800

func _ready():
	GameManager.boot_scene = self
	# Create basic cards
	GameManager.get_card(Res.team_alien)
	print("Team Alien Created")
	GameManager.get_card(Res.team_enemy)
	print("Team Enemy Created")
	# Load Object to Pool
	Pool.load_object(Res.hit_fx, FX_LOAD_AMOUNT)
	Pool.load_object(Res.death_fx, FX_LOAD_AMOUNT)
	Pool.load_object(Res.unit, UNIT_LOAD_AMOUNT)
	Pool.load_object(Res.expiriance, ENTITIES_LOAD_AMOUNT)
	Pool.load_object(Res.vanishing_text, 800)
	Pool.load_object(Res.card_holder, 5)
	Pool.load_object("res://content/units/bullets/Bullet.tscn", BULLETS_LOAD_AMOUNT)
	# After All Operations Switch Scene
	GameManager.go_to_scene(Res.gamescene.instance())
