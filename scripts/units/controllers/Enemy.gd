extends Controller
class_name Enemy

func on_add():
	name = "EnemyController"
	GameManager.enemies.append(unit)
	unit.team = Res.team_enemy
	unit.collision_layer = 0b1100
	unit.collision_mask = 0b0100
	
func on_kill():
	var expiriance:Energy = Pool.take_node(Res.energy)
	expiriance.position = global_position
	expiriance.amount = rand_range(unit.energy_drop.x, unit.energy_drop.y)
	expiriance.add()
	
func on_remove():
	GameManager.enemies.erase(unit)

func _process(delta):
	unit.moving = false
	# target equal to Null
	if not unit.target:
		_find_target()
		unit.can_shoot = false
		return
	# if target on scene but not added
	if not unit.target.visible: 
		unit.target = null
		unit.can_shoot = false
		return
	# Angle to Target in rad
	var angle = unit.target.position.angle_to_point(unit.position)
	# Check if Target in unit shoot_angle
	# TODO: Add shoot_angle to Unit
	unit.can_shoot =  Angles.angle_dist(unit.rotation - 1.5708, angle) < deg2rad(15)
	unit.moving = true
	unit.rotate_to_point(unit.target.position, unit.rotation_speed * Angles.degg2rad)
	unit.move_by_rotation()

func _find_target():
	# In priority we find player, after player Drones/Units
	unit.target = GameManager.get_player()
	if unit.target == null:
		unit.target = GameManager.get_closest_alien(unit)
