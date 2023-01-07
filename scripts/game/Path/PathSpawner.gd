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

var debug:bool = false # Shows lines/sprites
var finished:bool = false # In Main loop used to check when it ready for use

func _ready():
	points = [] # Create Empty Array
	randomize()
	spawn_path() # Start Spawn Generation
# Used only when points added to Create Boubles
func _physics_process(_delta):
	for i in points.size():
		var point:RigidBody2D = points[i]
		# When one of all points is sleeping we start connecting them
		if point.sleeping:
			create_path_points()
			points = []
			return
# That method connect All points for another's and set self.data for PathData variable
# when generator is finished set finished = true
# before use PathSpawner.data check when it will be finished
func create_path_points():
	path_positions = []
	special_points = []
	# Set Start point
	start_point = points[0]
	# Iterate every Point on them Map and find circle with smallest radius
	for i in points.size():
		var point:CollisionShape2D = points[i].get_child(0)
		# Check if best point radius less than current
		if point.shape.radius < start_point.get_child(0).shape.radius:
			start_point = point.get_parent()
			# Set Best point to current
			start_point = points[i]
	# Distance for start point to finish point
	var farrest_distance:float = 0
	# Iterate every Point and Find Circle farrest from start point
	for i in points.size():
		var point:RigidBody2D = points[i]
		# Skip if start point equal to them self
		randomize()
		if start_point == null: 
			for child in get_children():
				remove_child(child)
			spawn_path()
			return
		if point == start_point: continue
		if point.position.distance_squared_to(start_point.position) > farrest_distance:
			# Set distance/finish_point to distance/point between this point and start point
			farrest_distance = point.position.distance_squared_to(start_point.position)
			finish_point = point
	# Create Additional Points
	for i in special_points_count:
		# Additional points like not a Main Missions in the game | (aka) Clear Attack to the Planet
		special_points.append(choose_point_except_used())
	if has_shop:
		# Create only one shop on the map
		shop_point = choose_point_except_used()
	# Create Path's for points
	for i in points.size():
		var point:RigidBody2D = points[i]
		# This array says to current point with which point it must create Path
		var previus_best_point = []
		previus_best_point.append(points[i])
		# Every Point can connect only with 2 members, setted by value 2
		var path_point = PathPoint.new(point.position)
		for k in 2:
			# 9999 * 9999 in square distance
			var min_dst = 99980001
			# Set best point to 0 and try to find most closest point to this 
			# Exclude last time added point 
			var bestPoint:RigidBody2D = points[0]
			for n in points.size():
				# Another point in this Cycle
				var point2:RigidBody2D = points[n]
				# Continue when point was added to array and if point equal to them self
				if previus_best_point.has(point2): continue
				if point == point2: continue
				# Check distance and set to best point when it more than last best point
				var dst = point.position.distance_squared_to(point2.position)
				if dst < min_dst:
					min_dst = dst
					bestPoint = point2
			previus_best_point.append(bestPoint)
			var second_point = PathPoint.new(bestPoint.position)
			path_point.connect_point(second_point)
			# DEBUG ONLY | CREATE LINES BETWEEN CONNECTED POINTS
			if debug:
				var line = Line2D.new()
				line.modulate.a = .2
				line.add_point(point.position, 0)
				line.add_point(bestPoint.position, 0)
				add_child(line)
		# Add point to Array of points
		path_points.append(path_point)
		# DEBUG ONLY | CREATE SPRITES ON POINT POSITIONS
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
	# When generator finished, it set data to PathData from path_points array
	data = add_path_data()
	finished = true

func add_path_data():
	# Create Special DataContainer for Path
	var path_data = PathData.new()
	path_data.set_path_points(path_points)
	path_data.set_start_point(start_point)
	path_data.set_shop_point(shop_point)
	path_data.set_special_points(special_points)
	path_data.set_finish_point(finish_point)
	
	var min_x:float = 99999
	var min_y:float = 99999
	var max_x:float = 0
	var max_y:float = 0
	# Calculate Points width/height to divide all points on this value
	for point in path_data.path_points:
		if point.pos.x < min_x:
			min_x = point.pos.x
		if point.pos.x > max_x:
			max_x = point.pos.x
		if point.pos.y < min_y:
			min_y = point.pos.y
		if point.pos.y > max_y:
			max_y = point.pos.y
	# Set Every Point Position Between -1 and 1
	for point in path_data.path_points:
		point.pos.x = point.pos.x / max_x
		point.pos.y = point.pos.y / max_y
		for con in point.connections:
			con.pos.x = con.pos.x / max_x
			con.pos.y = con.pos.y / max_y
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
