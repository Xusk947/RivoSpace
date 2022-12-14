class_name PathPoint

var pos:Vector2 # Position of the Point
var connections:Array # Connections to other points

func _init(position:Vector2):
	self.pos = Vector2(position.x, position.y)
	connections = []
	
func connect_point(path:PathPoint):
	if connections.has(path): return
	connections.append(path)

func _to_string() -> String:
	return "[PathPoint:" + String(get_instance_id()) + " " + String(int(pos.x * 100) / 100.0) + "," + String(int(pos.y * 100) / 100.0) + " ]"
