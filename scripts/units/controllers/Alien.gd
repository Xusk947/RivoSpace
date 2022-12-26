extends Controller
class_name Alien

func on_add():
	name = "Alien"
	unit.team = Res.team_alien
	unit.collision_layer = 0b1010
	unit.collision_mask = 0b0010
	GameManager.aliens.append(unit)

func on_remove():
	GameManager.aliens.erase(unit)

func _process(_delta):
	unit.moving = false
	# Check if our Target exist and still alive
	if not unit.target:
		_find_target()
		unit.can_shoot = false
		return
	if unit.target.killed:
		unit.target = null
		_find_target()
		unit.can_shoot = false
		return
	# When we have target we move to it, and try to shoot
	unit.moving = true
	# Angle From Unit to Target
	var angle = unit.target.position.angle_to_point(unit.position)
	# Check if Target is in shoot range
	# TODO: Add to Unit.shoot_angle
	# 1.5708 rad == 90 deg
	unit.can_shoot = Angles.angle_dist(unit.rotation - 1.5708, angle) < deg2rad(15)
	unit.rotate_to_point(unit.target.position, unit.rotation_speed * Angles.degg2rad)
	unit.move_by_rotation()

func _find_target():
	# First Priority is player target, after them we try to find Enemy Drones/Units
	var player = GameManager.get_player()
	if player:
		unit.target = player.target
	else:
		unit.target = GameManager.get_closest_enemy(unit)
