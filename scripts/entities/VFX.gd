extends AudioStreamPlayer2D
class_name VFX

var _inited:bool

func _ready():
	if _inited: return
	_inited = true
	connect("finished", self, "_sound_finished")
	
func _sound_finished():
	stream = null
	Pool.return_node(self)
