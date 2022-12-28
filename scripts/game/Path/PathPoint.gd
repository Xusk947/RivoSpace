class_name PathPoint

var pos:Vector2
var connections:Array

func _init(pos:Vector2):
	self.pos = Vector2(pos.x, pos.y)
	connections = []
	
func connect_point(path:PathPoint):
	connections.append(path)
	if path.connections.has(self): return
	path.connections.append(self)
