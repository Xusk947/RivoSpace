extends Sprite
class_name Weapon

export var reload:float
export(Resource) var type

onready var shoot_offset:Position2D = $Offset

var unit:Unit
var _timer:Timer

func _ready():
	if type is WeaponType:
		_timer = Timer.new()
		texture = type.texture
		_timer.wait_time = type.reload / 60
		_timer.connect("timeout", self, "_timer_up")
		_timer.autostart = true
		add_child(_timer)

func _process(delta):
	if unit:
		if not unit.target: return
		if not (unit.target is Unit): return
		if unit.target.killed: return
		rotate_to_point(unit.target.position, type.rotation_speed)

func _timer_up():
	if unit.can_shoot && unit.target:
		for i in (type.shots + unit.card.bullet_adding):
			_shoot(type.shoot_cone + unit.card.weapon_shoot_cone_adding)
		if len(type.shoot_sounds) > 0:
			GameManager.play_sound(type.shoot_sounds[rand_range(0, len(type.shoot_sounds))], unit.position)

func _shoot(angle:float = 0):
	var bullet:Bullet = Pool.take_node(type.bullet)
	bullet.position = shoot_offset.global_position
	var shoot_angle = global_rotation - 1.5708 + deg2rad(rand_range(-angle, angle))
	bullet.velocity = (Vector2(bullet.type.speed, 0)).rotated(shoot_angle)
	bullet.rotation = shoot_angle
	bullet.crit = randf() > unit.card.crit_multiplayer
	if bullet.crit:
		bullet.damage_multiplayer = unit.card.crit_multiplayer * unit.card.bullet_damage_multiplayer
	else:
		bullet.damage_multiplayer = unit.card.bullet_damage_multiplayer
	bullet.unit = unit
	bullet.modulate = unit.team
	bullet.add()

func rotate_to(angle:float, rot_speed:float):
	rotation = Angles.move_toward(rotation, angle, rot_speed)
#Rotate weapon to point with some speed
func rotate_to_point(pos:Vector2, rot_speed:float):
	rotation = Angles.move_toward(rotation, pos.angle_to_point(global_position) + 1.5708 - unit.rotation, 2  * rot_speed * Angles.degg2rad)
