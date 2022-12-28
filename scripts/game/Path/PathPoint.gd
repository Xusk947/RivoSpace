class_name PathPoint

var pos:Vector2 # Position of the Point
var connections:Array # Connections to other points

func _init(pos:Vector2):
	self.pos = Vector2(pos.x, pos.y)
	connections = []
	
func connect_point(path:PathPoint):
	connections.append(path)
	# Check if point already connected to this point we dont add it again
	if path.connections.has(self): return
	path.connections.append(self)
