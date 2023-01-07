extends Node
class_name PathData

var path_points:Array # Array<PathPoint>
var shop_point:PathPoint # You can buy somethin there, only 1 point per map
var start_point:PathPoint # That points says when Units will start their adventure
var finish_point:PathPoint # Finish point, last point on the Star Path
var special_points:Array # Points used for some Events, like help cargo unit

func get_rescaled(scale:float):
	var new_data:PathData = load("res://scripts/game/Path/PathData.gd").new()
	new_data.set_path_points(path_points)
	# Set Special Points in cloned Data 
	# Duplicate() method Doesn't support _init(...) with variables, just create empty constructor
	new_data.start_point = start_point
	new_data.shop_point = shop_point
	new_data.special_points = special_points
	new_data.finish_point = finish_point
	new_data.path_points = []
	for point in path_points:
		var new_point = PathPoint.new(point.pos * scale)
		for con in point.connections:
			var new_con = PathPoint.new(point.pos * scale)
			new_point.connect_point(new_con)
		new_data.path_points.append(new_point)
	return new_data

func set_path_points(arr:Array):
	path_points = arr.duplicate()
	
# Check Every Point Position and when it Equal to RigidBody2D position set it to name_point = rb.pos
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
