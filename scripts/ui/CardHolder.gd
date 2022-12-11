extends Control
class_name CardHolder

onready var anim:AnimationPlayer = $AnimationPlayer
onready var button:Button = $Button
onready var texture_rect:TextureRect = $TextureRect
onready var name_label:Label = $VBoxContainer/BottomPanel/MarginContainer/VBoxContainer/Name
onready var description:Label = $VBoxContainer/BottomPanel/MarginContainer/VBoxContainer/Description
export(Resource) var card:Resource

var can_move:bool = false
var needy:float
var added:bool # Called when cause spawn() function

func _ready():
	needy = 0
	added = false
	if card:
		texture_rect.texture = card.texture
		name_label.text = card.name
		description.text = card.description
		self_modulate = card.modulate_color
	else:
		card = Res.basic_card
	button.connect("mouse_entered", self, "_mouse_entered")
	button.connect("mouse_exited", self, "_mouse_exited")
	button.connect("pressed", self, "_pressed_down")
	Events.connect("card_begin_selected", self, "_begin_select") # Start Disappear Animation

func _process(delta):
	if can_move:
		rect_position = rect_position.linear_interpolate(Vector2(rect_position.x, needy), 0.01)
		if needy == rect_position.y:
			can_move = false
			needy = 0

func spawn(speed:float = 1):
	anim.play("spawn", -1, speed)
	added = true

func select():
	Events.emit_signal("card_begin_selected", self)

func _begin_select(card_holder:CardHolder):
	if card_holder == self:
		anim.play("selected")
		needy = 1000
		can_move = true
	else:
		anim.play("unselected")
		print("Unselected")

func end_select():
	Events.emit_signal("card_selected", card)
	Res.erase_card(card)

func _pressed_down():
	if anim.current_animation == "selected": return
	if anim.current_animation == "unselected": return
	if anim.current_animation == "spawn": return
	anim.play("selected")
# Touch outside the button
func _mouse_exited():
	if anim.current_animation == "selected": return
	if anim.current_animation == "unselected": return
	if anim.current_animation == "spawn": return
	anim.play_backwards("hover")
# Touch in Button
func _mouse_entered():
	if anim.current_animation == "selected": return
	if anim.current_animation == "unselected": return
	if anim.current_animation == "spawn": return
	anim.play("hover")
# Set pivot in Centre of all rect
func _repair_pivot():
	rect_pivot_offset = rect_size * rect_scale / 2
