extends Node2D
class_name PathMap

onready var canvas:CanvasLayer = $CanvasLayer
onready var stars:Node2D = $CanvasLayer/Stars

var path_data:PathData setget _set_path_data, _get_path_data
var _ship_point:PathSprite

func _ready():
	path_data = GameManager.path_data
	$CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Button.connect("button_down", self, "hide")
	_clear_children()
	_create_children_from_path()
	hide()

func _process(delta):
	if visible:
		var dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
		stars.position += dir * 10
		# Move and Rotate Point on Display
		if GameManager.main_ship && _ship_point:
			_ship_point.position = 200 * GameManager.main_ship.position / Difficult.get_difficult(Difficult.NORMAL).distance
			_ship_point.rotation = GameManager.main_ship.rotation
	else:
		stars.position = OS.window_size / 2

func _set_path_data(v):
	path_data = v

func _get_path_data():
	return path_data

func _set_visible(v):
	visible = v
	canvas.visible = v
	stars.visible = v

func _get_visible():
	return visible

func hide():
	canvas.visible = false
	.hide()

func show():
	canvas.visible = true
	.show()

# Remove All children
func _clear_children():
	for child in stars.get_children():
		if child is Sprite:
			Pool.return_node(child)
		else:
			child.free()
func update_points_color():
	for child in stars.get_children():
		if child is PathSprite:
			child.modulate = Color.whitesmoke
			if child.name == "ShipPoint": continue
			if child.point == GameManager.current_point:
				child.modulate = Color.lime
			elif child.point == GameManager.path_data.finish_point:
				child.modulate = Color.red
			elif child.point == GameManager.path_data.shop_point:
				child.modulate = Color.yellow
			else:
				for sp in GameManager.path_data.special_points:
					if child.point == sp:
						child.modulate = Color.orangered
# Transform Path Data to Display
func _create_children_from_path():
	stars.position += OS.window_size / 2
	_ship_point = Pool.take_node(Res.path_sprite)
	_ship_point.name = "ShipPoint"
	_ship_point.z_index = 2
	_ship_point.scale = Vector2(1.5, 1.5)
	_ship_point.modulate = Color.crimson
	# Set Ship Point to Local Main Ship Position 
	if GameManager.main_ship && _ship_point:
		_ship_point.position = 200 * GameManager.main_ship.global_position / Difficult.get_difficult(Difficult.NORMAL).distance
		_ship_point.rotation = GameManager.main_ship.rotation

	stars.add_child(_ship_point)
	for path in path_data.path_points:
		var point:PathSprite = Pool.take_node(Res.path_sprite)
		point.z_index = 1
		point.name = "PathPoint"
		point.rotation_degrees = rand_range(0, 360)
		point.position = Vector2(path.pos.x, path.pos.y) * 200
		point.get_child(0).connect("button_down", self, "_button_down", [point])
		point.get_child(0).connect("mouse_entered", self, "_mouse_entered", [point])
		point.get_child(0).connect("mouse_exited", self, "_mouse_exited", [point])
		point.point = path
		point.scale = Vector2(2, 2)
		for con in path.connections:
			var line = Line2D.new()
			line.add_point(point.position)
			line.add_point(Vector2(con.pos.x, con.pos.y) * 200)
			stars.add_child(line)
			line.modulate.a = 1
			line.default_color = Color.gray
			if GameManager.main_ship && GameManager.main_ship.controller:
				if con == GameManager.main_ship.controller.move_to_point && point == GameManager.current_point:
					line.default_color = Color.red
		stars.add_child(point)
	update_points_color()

func _button_down(point:PathSprite):
	for con in point.point.connections:
		if con.pos == GameManager.current_point.pos:
			_select_point(point.point)
			return
	for con in GameManager.current_point.connections:
		if con.pos == point.point.pos:
			_select_point(point.point)
			return

func _select_point(point:PathPoint):
	GameManager.move_to_point = point
	GameManager.play_sound(Res.star_path_select_vfx, global_position, 1.25)

func _mouse_entered(point:Sprite):
	point.modulate.a = 0.5

func _mouse_exited(point:Sprite):
	point.modulate.a = 1
