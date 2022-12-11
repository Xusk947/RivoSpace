extends Node2D

# Current Game Data Storage
var boot_scene:BootScene
var scene_holder:SceneHolder

var players:Array = []
var aliens:Array = []
var enemies:Array = []
# Card Region
var selected_cards:Array = []
var cards:Dictionary = {}

var camera:FollowingCamera2D

var area:Area2D # Need for Fast Physics check
var shape:CollisionShape2D 

func _ready():
	area = Area2D.new()
	shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	area.add_child(shape)

func go_to_scene(scene:SceneHolder):
	if scene_holder != null:
		scene_holder.out()
	scene_holder = scene
	scene_holder.entter()
	boot_scene.add_child(scene_holder)

func get_enemy():
	if enemies.size() > 0:
		return enemies[0]
	return null
## Return closest enemy unit from given unit
## In Saved enemy array
func get_closest_enemy(unit:Unit, radius = 250):
	if enemies.size() > 0:
		var best = enemies[0]
		var dst2:float = 999999
		for e in enemies:
			if "Enemy" in e:
				var enemy_dst2 = unit.position.distance_squared_to(e.position)
				if enemy_dst2 < dst2:
					best = e
					dst2 = enemy_dst2
		return best
	return null

func get_closest_alien(unit:Unit, radius = 250):
	if aliens.size() > 0:
		var best = aliens[0]
		var dst2:float = 999999
		for a in aliens:
			if "Alien" in a:
				var enemy_dst2 = a.position.distance_squared_to(unit.position)
				if enemy_dst2 < dst2:
					best = a
					dst2 = enemy_dst2
		return best
	return null

func get_alien():
	if aliens.size() > 0:
		return aliens[0]
	return null 

func get_player():
	if players.size() > 0:
		return players[0]
	return null

func get_closest_player():
	return null #TODO finish

func add(node:Node2D):
	scene_holder.add_child(node)

func add_card(card:Card, team:Color):
	get_card(team).add(card)
	selected_cards.append(card)

func get_card(team:Color) -> Card: 
	if cards.has(team.to_html(false)):
		print("Return Existed Card:", cards[team.to_html(false)])
		return cards[team.to_html(false)]
	cards[team.to_html(false)] = Res.basic_card.duplicate()
	print("Return Created Card:", cards[team.to_html(false)])
	return Res.basic_card
