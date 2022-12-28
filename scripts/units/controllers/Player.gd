extends Controller
class_name Player

export var is_ai:bool = false

var _target_ticker:float = .5
var _last_alpha:float = 0
func on_add():
	name = "PlayerController"
	unit.name = "Player"
	unit.collision_layer = 0b1010
	unit.collision_mask = 0b0010
	Events.emit_signal("player_spawned", {player = unit})
	GameManager.players.append(unit)
	unit.team = Res.team_alien

func on_kill():
	Events.emit_signal("player_killed", {player = unit})

func on_remove():
	GameManager.players.erase(unit)

func _process(delta):
	if unit.modulate.a < 1 and _last_alpha == unit.modulate.a:
		unit.modulate.a = lerp(unit.modulate.a, 1, 0.2)
	_last_alpha = unit.modulate.a
	_target_update(delta)
func _target_update(delta):
	# Find closest enemy every .1 sec
	_target_ticker -= delta
	if _target_ticker < 0:
		_target_ticker = 1
		_find_target()
	if is_ai:
		_update_ai(delta)
	else:
		_update_keyboard(delta)
	if not unit.target:
		_find_target()
		unit.can_shoot = false
	else:
		# Can shoot if target exist
		unit.can_shoot = true
		if unit.target.killed:
			_find_target()
func _update_keyboard(delta):
	var vel = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_down", "move_up"))
	unit.rotation += unit.rotation_speed * Angles.degg2rad * vel.x
	unit._change_thruster_direction(unit.rotation_dir)
	unit.moving = false
	if (Mathf.abs(vel.y) > 0):
		unit.move_by_rotation()
		unit.moving = true

func _find_target():
	unit.target = GameManager.get_closest_enemy(unit)

func _update_joystick(delta):
	pass
	
# FOR FUTURE
func _update_ai(deltla):
	pass
