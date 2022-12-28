extends Node2D
class_name PathSpawner
export var tex:Texture

var data:PathData # Export value get when finished
var points:Array
var path_positions:Array

var start_point:RigidBody2D # Start RigidBody2D
var finish_point:RigidBody2D # Finish RigidBody2D
var shop_point:RigidBody2D # Shop RigidBody2D
var special_points:Array # Array<RigidBody2D>
var special_points_count:int = 1 # For Some interesting rooms, like MiniBoss
var has_shop:bool = true # Star Path has shop?
var size:Vector2 = Vector2(5, 8) # Size of Star Path
var scale_factor = 5.0 # For Distance Between Points
var path_points:Array # Array<PathPoint>

var debug:bool = false
var finished:bool = false

func _ready():
	points = []
	spawn_path()

func _physics_process(delta):
	for i in points.size():
		var point:RigidBody2D = points[i]
		if point.sleeping:
			create_path_points()
			points = []
			return

func create_path_points():
	path_positions = []
	special_points = []
	# Set Start point
	var smallest_shape:CollisionShape2D = points[0].get_child(0)
	# Check Every Point on them Map and find circle with smallest radius
	for i in points.size():
		var point:CollisionShape2D = points[i].get_child(0)
		if point.shape.radius < smallest_shape.shape.radius:
			smallest_shape = point
			start_point = points[i]
	var old_farest:float = 0
	# Check Every Point and Find Circle farrest from start point
	for i in points.size():
		var point:RigidBody2D = points[i]
		if point == start_point: continue
		if point.position.distance_squared_to(start_point.position) > old_farest:
			old_farest = point.position.distance_squared_to(start_point.position)
			finish_point = point
	# Create Additional Points
	for i in special_points_count:
		special_points.append(choose_point_except_used())
	if has_shop:
		shop_point = choose_point_except_used()
	# Create Path's for points
	for i in points.size():
		var point:RigidBody2D = points[i]
		var previus_best_point = []
		previus_best_point.append(points[i])
		# Every Point can connect only with 2 members
		for k in 2:
			var min_dst = 9999 * 9999
			var bestPoint:RigidBody2D = points[0]
			for n in points.size():
				var point2:RigidBody2D = points[n]
				if previus_best_point.has(point2): continue
				if point == point2: continue
				var dst = point.position.distance_squared_to(point2.position)
				if dst < min_dst:
					min_dst = dst
					bestPoint = point2
			previus_best_point.append(bestPoint)
			# DEBUG ONLY
			var path_point = PathPoint.new(point.position)
			var second_point = PathPoint.new(bestPoint.position)
			path_point.connect_point(second_point)
			path_points.append(path_point)
			if debug:
				var line = Line2D.new()
				line.modulate.a = .2
				line.add_point(point.position, 0)
				line.add_point(bestPoint.position, 0)
				add_child(line)
		# DEBUG ONLY
		if debug:
			var sprite = Sprite.new()
			sprite.texture = tex
			sprite.position = point.position
			sprite.scale = Vector2(scale_factor, scale_factor)
			if point == start_point:
				sprite.modulate = Color.lime
			if point == finish_point:
				sprite.modulate = Color.red
			if special_points.has(point):
				sprite.modulate = Color.blue
			if point == shop_point:
				sprite.modulate = Color.yellow
			add_child(sprite)
	finished = true
	data = add_path_data()

func add_path_data():
	var path_data = PathData.new(path_points)
	path_data.set_start_point(start_point)
	path_data.set_shop_point(shop_point)
	path_data.set_special_points(special_points)
	path_data.set_finish_point(finish_point)
	return path_data
	

func choose_point_except_used():
	# Search Through all Points and find Free one
	for i in points.size():
		var point:RigidBody2D = points[i]
		if point == start_point: continue
		if point == shop_point: continue
		if point == finish_point: continue
		if special_points.has(point): continue
		return point

func spawn_path():
	finished = false
	points = []
	for child in get_children():
		if child is Camera2D: continue
		if child.get_parent() != self: continue
		remove_child(child)
	for i in int(rand_range(size.x, size.y)):
		# Create RigidBody2D
		var body = RigidBody2D.new()
		# Create Collision Shape Node
		var col_shape = CollisionShape2D.new()
		# Craete Circle Shape for Collision Node 
		var shape = CircleShape2D.new()
		shape.radius = rand_range(50 * scale_factor, 100 * scale_factor)
		# Apply Shape to Collision Node
		col_shape.shape = shape
		# Add Collision Shape as a Child to RigidBody2D
		body.add_child(col_shape)
		# Remove Gravity
		body.gravity_scale = 0
		# Add RigidBody2D for this Node
		add_child(body)
		# Set Random position 
		# Remove Straight Circle's spawn
		body.position = Vector2(rand_range(-25, 25), rand_range(-25, 25))
		# Add RigidBody2D for spawned Points
		points.append(body)
