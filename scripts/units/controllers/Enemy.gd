extends Controller
class_name Enemy

func on_add():
	GameManager.enemies.append(unit)
	unit.team = Res.team_enemy
	unit.collision_layer = 0b1100
	unit.collision_mask = 0b0100
	
func on_kill():
	var expiriance:Exp = Pool.take_node(Res.expiriance)
	expiriance.position = global_position
	expiriance.add()
	
func on_remove():
	GameManager.enemies.erase(unit)

func _process(delta):
	unit.moving = false
	if not unit.target:
		_find_target()
		unit.can_shoot = false
		return
	if not unit.target.visible: 
		unit.target = null
		unit.can_shoot = false
		return
	unit.can_shoot = true
	unit.moving = true
	unit.rotate_to_point(unit.target.position, unit.rotation_speed * Angles.degg2rad)
	unit.move_by_rotation()

func _find_target():
	unit.target = GameManager.get_player()
	if unit.target == null:
		unit.target = GameManager.get_closest_alien(unit)
