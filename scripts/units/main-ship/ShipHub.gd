extends Node2D
class_name ShipHub

onready var body:Sprite = $ShipBody # Sprite Body
onready var spawn_position:Position2D = $SpawnPosition # When PlayerCharacted will be spawned
onready var ship_zones:Node2D = $ShipZones # Zones for Enttered Ships

var players_in_hub:Array
var players_to_spawn:Array
var unit_owner:Unit

func _ready():
	players_in_hub = []
	players_to_spawn = []

func _process(delta):
	visible = players_in_hub.size() > 0
	for player_character in players_in_hub:
		if player_character.can_exit:
			player_out_from_hub(player_character)

func player_enter_to_hub(unit:Unit) -> bool:
	var zone:Sprite = _get_free_spawn_zone()
	if not zone: return false
	# Create Player Character and set unit and where unit placed for them
	var player_character:PlayerCharacter = Pool.take_node(Res.player_character)
	player_character.unit = unit
	player_character.position = spawn_position.position
	# Add Player Character to ShipHub Node
	add_child(player_character)
	players_in_hub.append(player_character)
	player_character.zone = zone
	# Set camera for PlayerCharacter placed in the ship
	zone.texture = unit.body.texture.duplicate()
	var scale_zone = Vector2(48.0 / zone.texture.get_width(), 48.0 / zone.texture.get_height())
	zone.scale = scale_zone
	zone.rotation_degrees = rand_range(-180, 180)
	# Unit Disable
	unit.visible = false
	unit.set_process(false)
	unit.set_physics_process(false)
	unit.modulate.a = 1
	unit.velocity = Vector2.ZERO
	GameManager.camera.set_target(player_character, 0.2)
	# Hide All UI when player enttered to the ShipHub
	if GameManager.scene_holder is GameScene:
		var scene:GameScene = GameManager.scene_holder
		scene.update_in_hub_ui(true)
	return true

func _get_free_spawn_zone():
	var arr = ship_zones.get_children().duplicate()
	arr.shuffle()
	for zone in arr:
		if zone is Sprite:
			if zone.texture == null:
				print(zone)
				return zone
	return null

func player_out_from_hub(player_character:PlayerCharacter):
	# Reset duplicated texture to null
	player_character.zone.texture = null
	remove_child(player_character)
	players_in_hub.erase(player_character)
	players_to_spawn.append(player_character)
	# Remove Fx Node
	Pool.return_node(player_character)
	if GameManager.scene_holder is GameScene:
		var scene:GameScene = GameManager.scene_holder
		scene.update_in_hub_ui(false)
