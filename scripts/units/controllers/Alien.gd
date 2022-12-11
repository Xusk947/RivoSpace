extends Controller
class_name Alien

func on_add():
	unit.team = Res.team_alien
	unit.collision_layer = 0b1010
	unit.collision_mask = 0b0010
	GameManager.aliens.append(unit)

func on_remove():
	GameManager.aliens.erase(unit)

func _process(_delta):
	unit.moving = false
	if not unit.target:
		_find_target()
		unit.can_shoot = false
		return
	if unit.target.killed:
		unit.target = null
		_find_target()
		unit.can_shoot = false
		return
	unit.moving = true
	unit.can_shoot = true
	unit.rotate_to_point(unit.target.position, unit.rotation_speed * Angles.degg2rad)
	unit.move_by_rotation()

func _find_target():
	var player = GameManager.get_player()
	if player:
		unit.target = player.target
	else:
		unit.target = GameManager.get_closest_enemy(unit)
