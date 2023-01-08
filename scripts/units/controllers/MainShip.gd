extends Controller
class_name MainShip

var spawn_point:Position2D # Point when player will be spawned
var path_data:PathData # Path data for ship movement and showing in PathScreen
var ship_hub:ShipHub # Ship hub / area for interactions
var energy_charge_zone:Area2D # Zone when Aliens ship can charge their battery
var ship_entter_zone:Area2D # When player entter in this zone, player ship start animation
var engine_audio_stream:AudioStreamPlayer2D # Main Ship Engine Audio Strem
var _units_in_charge_zone:Array # Array with Ships to Charge
var _units_in_entter_zone:Array # Array with Players to Entter in Ship hub
var _slow_down_sound_played:bool # Activates when unit close to point and slow down ship

func on_add():
	name = "MainShipController"
	# Find Spawn Point Node
	spawn_point = unit.find_node("UnitSpawnPoint", false)
	# Find Ship Hub node
	ship_hub = unit.find_node("ShipHub", false)
	# Find Engine Audio Stream
	engine_audio_stream = unit.find_node("EngineAudioStream")
	engine_audio_stream.playing = false
	# Energy Charge Zone Signal / To charge ships in Zone
	energy_charge_zone = unit.find_node("ChargerZone")
	energy_charge_zone.connect("body_shape_entered", self, "_unit_entter_to_charge_zone")
	energy_charge_zone.connect("body_shape_exited", self, "_unit_out_from_charge_zone")
	_units_in_charge_zone = [] # Create / Clear Used Array
	# Ship Entter Zone / Place Ship in Zone  
	ship_entter_zone = unit.find_node("ShipEntterZone")
	ship_entter_zone.connect("body_shape_entered", self, "_unit_entter_to_ship_entter_zone")
	ship_entter_zone.connect("body_shape_exited", self, "_unit_out_from_ship_entter_zone")
	_units_in_entter_zone = [] # Create / Clear Used Array
	# Set Main Ship as an owner of ShipHub
	ship_hub.unit_owner = unit
	unit.collision_layer = 0b1000 # Can't collide with aliance units, but can with enemy
	unit.collision_mask = 0b0100
	unit.team = Res.team_alien
	# Creating First player be like | TODO: remove and add fully player system
	ship_hub.player_enter_to_hub(_create_unit())
	GameManager.main_ship = unit
# Only for debbugin, create empty unit and pull it into the ShipHub
func _create_unit():
	var unit:Unit = Pool.take_node(Res.unit)
	unit.position = spawn_point.global_position
	unit.rotation = 0
	unit.controller_script = Res.player
	unit.add()
	return unit
# When MainShip is killed we kill all players on the map
func on_kill():
	if GameManager.get_player(): # Change to get_all players
		GameManager.get_player().kill()
	if GameManager.get_alien():
		GameManager.camera.set_target(GameManager.get_alien(), 1)
	elif GameManager.get_enemy():
		GameManager.camera.set_target(GameManager.get_enemy(), 1)

func on_remove():
	pass

func _process(delta):
	# If ShipHub have player who leave it, we spawn new Unit with PlayerCharacted data
	if ship_hub.players_to_spawn.size() > 0:
		# Get First Player from Array 
		var player_character:PlayerCharacter = ship_hub.players_to_spawn[0]
		# Spawn PlayerCharacter.unit on the MainShip.spawn_point
		spawn_player_from_hub(player_character)
		ship_hub.players_to_spawn.erase(player_character)
	# Moving by path
	unit.moving = false
	if GameManager.current_point && GameManager.move_to_point:
		# Get target point global position
		var point_world_position = GameManager.move_to_point.pos * Difficult.get_difficult(Difficult.NORMAL).distance
		# Calculate distance between target point and unit position
		var dst = unit.position.distance_to(point_world_position)
		if dst > 500:
			# Rotate from current point to point where unit will be go
			var angle = point_world_position.angle_to_point(unit.position) + deg2rad(90)
			unit.rotate_to(angle, unit.rotation_speed * Angles.degg2rad * delta)
			
			var angle_dist = Angles.angle_dist(unit.rotation - 1.5708, angle)
			
			unit.moving = true
			unit.move_by_rotation()
		else:
			var lenght = unit.velocity.length()
			unit.moving = lenght > 25
			unit.velocity *= 0.98
			if not _slow_down_sound_played:
				GameManager.play_sound(Res.engines_slow_down_vfx, global_position)
				_slow_down_sound_played = true
			if lenght < 10:
				GameManager.current_point = GameManager.move_to_point
				GameManager.move_to_point = null
				ship_hub.path_map.update_points_color()
				unit.velocity = Vector2.ZERO
				_slow_down_sound_played = false
	# Adjust Engine Audio Stream Player to Ship Movement
	if unit.moving && engine_audio_stream.volume_db < 8:
		engine_audio_stream.volume_db += 0.1
		engine_audio_stream.play()
	elif !unit.moving && engine_audio_stream.volume_db > 0:
		engine_audio_stream.volume_db -= 0.1
		if engine_audio_stream.volume_db < 0:
			engine_audio_stream.stop()
	# Iterate all units in charge zone and charge them;
	for transfer_unit in _units_in_charge_zone:
		# Charge Unit by 1%
		var power = transfer_unit.max_energy / 100
		# Check if alien energy less then it maximum
		if unit.energy > power and (transfer_unit.max_energy - transfer_unit.energy) > power:
			# Charging Alien's unit cost some energy
			transfer_unit.energy += power
			unit.energy -= power
	# Iterate every Player in Entter Zone
	for entter_unit in _units_in_entter_zone:
		# When Player alpha less than 0.001 put player ship in to ShipHub
		entter_unit.modulate.a = lerp(entter_unit.modulate.a, 0, 0.1)
		if entter_unit.modulate.a < 0.001 and entter_unit.visible:
			ship_hub.player_enter_to_hub(entter_unit)
			_units_in_entter_zone.erase(entter_unit)
	# Update Target for turrets
	_target_update(delta)

func spawn_player_from_hub(player_character:PlayerCharacter):
	# We get putted unit from player_character
	var player:Unit = player_character.unit
	# Restart all variables and show it to the Player Screen
	player.velocity = Vector2.ZERO
	player.rotation = 0
	player.set_process(true)
	player.set_physics_process(true)
	player.visible = true
	player.modulate.a = 1.0 # Unit move to ShipHub when modulate equal to 0, we change it to 1.0
	player.position = spawn_point.global_position
	# Set Camera to Player Ship when it Spawned
	Pool.return_node(player_character)
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
		# Check Body if it Unit
		var parent = body.shape_owner_get_owner(body_shape_idx).get_parent()
		if parent is Unit:
			# Main ship works only for team 
			if not parent.team == unit.team: return null
			return parent
	return null

func _find_target():
	# First Priority is player target, after them we try to find Enemy Drones/Units
	var player = GameManager.get_player()
	if player:
		unit.target = player.target
	else:
		unit.target = GameManager.get_closest_enemy(unit)
