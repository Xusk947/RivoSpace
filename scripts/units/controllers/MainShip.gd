extends Controller
class_name MainShip

var spawn_point:Position2D
var path_data:PathData
var current_point:PathPoint
var move_to_point:PathPoint
var ship_hub:ShipHub
var energy_charge_zone:Area2D
var ship_entter_zone:Area2D

var _units_in_charge_zone:Array
var _units_in_entter_zone:Array

func on_add():
	name = "MainShipController"
	spawn_point = unit.find_node("UnitSpawnPoint", false)
	ship_hub = unit.find_node("ShipHub", false)
	# Energy Charge Zone Signal / To charge ships in Zone
	energy_charge_zone = unit.find_node("ChargerZone")
	energy_charge_zone.connect("body_shape_entered", self, "_unit_entter_to_charge_zone")
	energy_charge_zone.connect("body_shape_exited", self, "_unit_out_from_charge_zone")
	_units_in_charge_zone = []
	# Ship Entter Zone / Place Ship in Zone  
	ship_entter_zone = unit.find_node("ShipEntterZone")
	ship_entter_zone.connect("body_shape_entered", self, "_unit_entter_to_ship_entter_zone")
	ship_entter_zone.connect("body_shape_exited", self, "_unit_out_from_ship_entter_zone")
	_units_in_entter_zone = []
	
	ship_hub.unit_owner = unit
	unit.collision_layer = 0b1000
	unit.collision_mask = 0b0100
	unit.team = Res.team_alien
	ship_hub.player_enter_to_hub(_create_unit())
	visible = true
	GameManager.main_ship = unit

func _create_unit():
	var unit:Unit = Pool.take_node(Res.unit)
	unit.position = spawn_point.global_position
	unit.rotation = 0
	unit.controller_script = Res.player
	unit.add()
	return unit

func on_kill():
	if GameManager.get_player():
		GameManager.get_player().kill()
	if GameManager.get_alien():
		GameManager.camera.set_target(GameManager.get_alien(), 1)
	elif GameManager.get_enemy():
		GameManager.camera.set_target(GameManager.get_enemy(), 1)

func on_remove():
	pass

func _process(delta):
	visible = ship_hub.players_in_hub.size() > 0
	if ship_hub.players_to_spawn.size() > 0:
		var player_character:PlayerCharacter = ship_hub.players_to_spawn[0]
		spawn_player_from_hub(player_character)
		ship_hub.players_to_spawn.erase(player_character)
	unit.velocity = Vector2(0, -10)
	for transfer_unit in _units_in_charge_zone:
		# Charge Unit by 1%
		var power = transfer_unit.max_energy / 100
		transfer_unit.energy -= 1
	for entter_unit in _units_in_entter_zone:
		entter_unit.modulate.a = lerp(entter_unit.modulate.a, 0, 0.1)
		if entter_unit.modulate.a < 0.001 and entter_unit.visible:
			ship_hub.player_enter_to_hub(entter_unit)
			_units_in_entter_zone.erase(entter_unit)
	_target_update(delta)

func spawn_player_from_hub(player_character:PlayerCharacter):
	var player:Unit = player_character.unit
	player.controller_script = Res.player
	player.rotation = 0
	player.set_process(true)
	player.set_physics_process(true)
	player.visible = true
	player.position = spawn_point.global_position
	# Set Camera to Player Ship when it Spawned
	GameManager.camera.set_target(player, 1)

func _target_update(_delta):
	# Check if our Target exist and still alive
	unit.can_shoot = true
	if not unit.target: # if unit target not exist find new one
		_find_target()
		unit.can_shoot = false
		return
	if unit.target.killed: # If unit target killed we try to find new one
		unit.target = null
		_find_target()
		unit.can_shoot = false
		return

func _unit_entter_to_charge_zone(_rid:RID, body:Node, body_shape_idx, _local_shape_idx):
	var collision_unit:Unit = _get_unit(body, body_shape_idx)
	# Null Check
	if collision_unit:
		_units_in_charge_zone.append(collision_unit)

func _unit_out_from_charge_zone(_rid:RID, body:Node, body_shape_idx, _local_shape_idx):
	var collision_unit:Unit = _get_unit(body, body_shape_idx)
	# Null Check
	if collision_unit:
		# Check if Alien Unit exist in Array we erase it after
		if _units_in_charge_zone.has(collision_unit):
			_units_in_charge_zone.erase(collision_unit)
func _unit_entter_to_ship_entter_zone(_rid:RID, body:Node, body_shape_idx, _local_shape_idx):
	var collision_unit:Unit = _get_unit(body, body_shape_idx)
	# Null Check
	if collision_unit:
		if collision_unit.controller is Player:
			_units_in_entter_zone.append(body)

func _unit_out_from_ship_entter_zone(_rid:RID, body:Node, body_shape_idx, _local_shape_idx):
	var collision_unit:Unit = _get_unit(body, body_shape_idx)
	# Null Check
	if collision_unit:
		# Player unit not Exist in Array we return function
		if not _units_in_entter_zone.has(collision_unit): return
		# Then we check if Collision unit is Player we remove it
		if collision_unit.controller is Player:
			_units_in_entter_zone.erase(collision_unit)

# Get Collision Body and if body is Unit then we return It
func _get_unit(body:Node, body_shape_idx):
	if (body is PhysicsBody2D):
		var parent = body.shape_owner_get_owner(body_shape_idx).get_parent()
		if parent is Unit:
			if parent.team == Res.team_enemy: return null
			return parent
	return null

func _find_target():
	# First Priority is player target, after them we try to find Enemy Drones/Units
	var player = GameManager.get_player()
	if player:
		unit.target = player.target
	else:
		unit.target = GameManager.get_closest_enemy(unit)
