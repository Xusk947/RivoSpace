extends Sprite
class_name Weapon

export var reload:float
export(Resource) var type
onready var shoot_offset:Position2D = $Offset

var unit:Unit
var _timer:Timer

func _ready():
	if type is WeaponType:
		# Create timer, says when unit can shoot
		_timer = Timer.new()
		# For weapons installed in ship / can't rotate
		if type.texture:
			texture = type.texture
		# We set Time in #WeaponType in secs but in code use sec / 60.0 = tick
		_timer.wait_time = type.reload / 60
		_timer.connect("timeout", self, "_timer_up")
		# Start when Weapon is created
		_timer.autostart = true
		# Add timer as a child
		add_child(_timer)

func _process(delta):
	# If Weapon exist without unit
	if unit:
		if not type.can_rotate: return # Turret Can't rotate
		if not unit.target: return # Unit doesn't have target we return
		if not (unit.target is Unit): return # Target not a unit
		if unit.target.killed: return # Target is killed
		# Rotate directly to Target
		rotate_to_point(unit.target.position, type.rotation_speed)
# When Timer says us we can shoot
func _timer_up():
	if unit.can_shoot && unit.target: # Unit can shoot and has a target
		for i in (type.shots + unit.card.bullet_adding): # Iterate all #WeaponType.shots at once
			_shoot(type.shoot_cone + unit.card.weapon_shoot_cone_adding)
		if len(type.shoot_sounds) > 0: # When shoot create #WeaponType shoot sound if exist
			GameManager.play_sound(type.shoot_sounds[rand_range(0, len(type.shoot_sounds))], unit.position)

func _shoot(angle:float = 0):
	# Take a bullet from Object Pool 
	var bullet:Bullet = Pool.take_node(type.bullet)
	bullet.position = shoot_offset.global_position # Set Bullet position to global $ShootOffset position
	var shoot_angle = global_rotation - 1.5708 + deg2rad(rand_range(-angle, angle)) # Calculate Shoot angle, and minus 90 degree
	bullet.velocity = (Vector2(bullet.type.speed, 0)).rotated(shoot_angle)
	bullet.rotation = shoot_angle # Rotate bullet to shoot angle
	bullet.crit = randf() > unit.card.crit_multiplayer # Set crit Damage for bullet
	if bullet.crit:
		bullet.damage_multiplayer = unit.card.crit_multiplayer * unit.card.bullet_damage_multiplayer
	else:
		bullet.damage_multiplayer = unit.card.bullet_damage_multiplayer
	# Set Bullet unit, color, and add() it on the end
	bullet.unit = unit
	bullet.modulate = unit.team
	bullet.add()
# Rotate weapon to Specific Angle with rotation_speed
func rotate_to(angle:float, rot_speed:float):
	rotation = Angles.move_toward(rotation, angle, rot_speed)
# Rotate weapon to point with rotation_speed
func rotate_to_point(pos:Vector2, rot_speed:float):
	rotation = Angles.move_toward(rotation, pos.angle_to_point(global_position) + 1.5708 - unit.rotation, 2  * rot_speed * Angles.degg2rad)
