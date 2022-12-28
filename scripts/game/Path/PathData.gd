extends Node
class_name PathData

var path_points:Array # Array<PathPoint>
var shop_point:PathPoint # You can buy somethin there, only 1 point per map
var special_points:Array # Points used for some Events, like help cargo unit
var start_point:PathPoint # That points says when Units will start their adventure
var finish_point:PathPoint # Finish point, last point on the Star Path

func _init(path_points:Array):
	self.path_points = path_points.duplicate()

func set_shop_point(point:RigidBody2D):
	for path_point in path_points:
		if path_point is PathPoint:
			if point.position == path_point.pos:
				shop_point = path_point
				return
func set_start_point(point:RigidBody2D):
	for path_point in path_points:
		if path_point is PathPoint:
			if point.position == path_point.pos:
				start_point = path_point
				return
func set_finish_point(point:RigidBody2D):
	for path_point in path_points:
		if path_point is PathPoint:
			if point.position == path_point.pos:
				finish_point = path_point
				return

func set_special_points(points:Array):
	special_points = []
	for path_point in path_points:
		if path_point is PathPoint:
			for point in points:
				if point.position == path_point.pos:
					special_points.append(PathPoint.new(point.position))
