extends Node2D
class_name WaveSpawner

var weak_wave:Array # Easy Wave
var normal_wave:Array # Normal Wave
var difficult_wave:Array # Hard Wave
var current_waves:Array # Current Updating Waves

func _ready():
	_init_weak_waves()
	_init_normal_waves()
	_init_difficult_waves()
	current_waves = []

func _init_difficult_waves():
	difficult_wave = []

func _init_normal_waves():
	normal_wave = []

func _init_weak_waves():
	weak_wave = []

func _process(delta):
	for wave in current_waves:
		if wave is Wave:
			if not wave.spawner:
				wave.start()
			wave._process(delta)
			if wave.finished:
				current_waves.erase(wave)

func _get_boss_wave(_hardness:int = 0):
	return []

func _get_difficult_wave():
	return []

func _get_normal_wave():
	return []

func _get_weak_wave():
	return []

class Wave:
	var spawner:WaveSpawner
	var unit:String
	var amount:int
	var delay:float
	var finished:bool = false
	
	var _spawned:bool = false
	var _units_spawned:int = 0
	var _timer:float
	var spawn_sides:Array
	# Unit, Amount of units, delay between waves
	func _init(u:String, a:int, d:float, sides:Array = []):
		unit = u
		amount = a
		delay = d
		_timer = 0.0
		spawn_sides = sides
		_spawned = false
	
	func start(s:WaveSpawner):
		self.spawner = s
		self._spawned = true

	func _process(delta:float):
		if finished: return
		_timer -= delta
		if _timer < 0:
			_timer = delay
			var spawned_unit:Unit = Pool.take_node(unit)
			#var screen_size = GameManager.get_player().get_viewport().get_visible_rect().size
			spawned_unit.position = GameManager.get_player().position
			spawned_unit.add()
			_units_spawned += 1
			if _units_spawned == amount:
				finished = true

	func duplicate() -> Wave:
		return Wave.new(unit, amount, delay, spawn_sides)
