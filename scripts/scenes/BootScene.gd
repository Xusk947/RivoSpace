extends Node2D
class_name BootScene

const UNIT_LOAD_AMOUNT:int = 30
const ENTITIES_LOAD_AMOUNT:int = 30
const FX_LOAD_AMOUNT:int = 50
const BULLETS_LOAD_AMOUNT:int = 800

func _ready():
	GameManager.boot_scene = self
	_create_cards()
	_load_entities()
	_load_fx()
	_load_units()
	_load_bullets()
	GameManager.go_to_scene(Res.gamescene.instance())

func _create_cards():
	GameManager.get_card(Res.team_alien)
	GameManager.get_card(Res.team_enemy)

func _load_entities():
	Pool.load_object(Res.vanishing_text, 800)
	Pool.load_object(Res.energy, ENTITIES_LOAD_AMOUNT)
	Pool.load_object(Res.card_holder, 5)
	Pool.load_object(Res.player_character, 4)

func _load_units():
	Pool.load_object(Res.unit, UNIT_LOAD_AMOUNT)
	Pool.load_object(Res.sharp, UNIT_LOAD_AMOUNT)
	Pool.load_object(Res.trasher, UNIT_LOAD_AMOUNT)
	Pool.load_object(Res.main_ship_unit, 2) # add 1 for Future Uses

func _load_fx():
	Pool.load_object(Res.hit_fx, FX_LOAD_AMOUNT)
	Pool.load_object(Res.death_fx, FX_LOAD_AMOUNT)

func _load_bullets():
	Pool.load_object(Res.basic_bullet)
