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
			wave._process(delta)
			if wave.finished:
				current_waves.erase(wave)

func _get_boss_wave(hardness:int = 0):
	return []

func _get_difficult_wave():
	return []

func _get_normal_wave():
	return []
	
func _get_weak_wave():
	return []

class Wave:
	var unit:String
	var amount:int
	var delay:float
	var position:Vector2
	var finished:bool = false
	
	var _spawned:int = 0
	var _timer:float
	
	func _init(unit:String, amount:int, delay:float, position:Vector2 = Vector2.ZERO):
		self.unit = unit
		self.amount = amount
		self.delay = delay
		self._timer = 0.0

	func _process(delta:float):
		if finished: return
		_timer -= delta
		if _timer < 0:
			_timer = delay
			var unit:Unit = Pool.take_node(unit)
			unit.position = position
			unit.add()
			_spawned += 1
			if _spawned == amount:
				finished = true
	
	func duplicate() -> Wave:
		return Wave.new(unit, amount, delay)
