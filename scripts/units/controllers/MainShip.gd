extends Controller

var spawn_point:Position2D

func on_add():
	name = "MainShipController"
	spawn_point = unit.find_node("UnitSpawnPoint", false)
	unit.collision_layer = 0b0000
	unit.collision_mask = 0b0100
	unit.team = Res.team_alien
	GameManager.main_ship = unit

func on_kill():
	GameManager.get_player().kill()
	
func on_remove():
	pass

func _process(delta):
	if GameManager.players.size() < 1:
		_spawn_player()
	unit.velocity = Vector2(0, -10)

func _spawn_player():
	var player:Unit = Pool.take_node(Res.unit)
	player.controller_script = Res.player
	player.rotation = 0
	print(spawn_point.global_position)
	player.position = spawn_point.global_position
	player.add()
