extends Control
class_name CardHolder

onready var anim:AnimationPlayer = $AnimationPlayer
onready var button:Button = $Button
onready var texture_rect:TextureRect = $TextureRect
onready var name_label:Label = $VBoxContainer/BottomPanel/MarginContainer/VBoxContainer/Name
onready var description:Label = $VBoxContainer/BottomPanel/MarginContainer/VBoxContainer/Description
export(Resource) var card:Resource

var can_move:bool
var needy:float
var added:bool # Called when cause spawn() function

func _ready():
	# Restart Parameters if card was selected, and added
	needy = 0
	can_move = false
	added = false 
	modulate.a = 0 # Hide out Card when we add it from Pool
	if card:
		# Set Texture, Name, Desciprion of our card
		texture_rect.texture = card.texture
		name_label.text = card.name
		description.text = card.description
		self_modulate = card.modulate_color
	else:
		card = Res.basic_card
	button.connect("mouse_entered", self, "_mouse_entered") # Mouse Entered to the Card
	button.connect("mouse_exited", self, "_mouse_exited") # Mouse Out from the Card
	button.connect("pressed", self, "_pressed_down") # Select card when Mouse is Pressed
	Events.connect("card_begin_selected", self, "_begin_select") # Start Disappear Animation

func _process(delta):
	if not added: return # Continue when card was finished "spawn" animtion
	if can_move:
		# That move card to bottom of the screen, because if we try it with AnimationPlayer
		# Out card set to Y, and from this Y start moving to needy
		# This function move card from current rect.y
		rect_position = rect_position.linear_interpolate(Vector2(rect_position.x, needy), 0.01)

func spawn(speed:float = 1):
	# Play spawn animation, and set card to added (aka) can hold events 
	anim.play("spawn", -1, speed)
	added = true

func select(): # When we select card we call Seng Global Signal
	# That's say to another cards we start disappear animation
	Events.emit_signal("card_begin_selected", self)

func _begin_select(card_holder:CardHolder):
	# When we hold mouse on Selected Card we need can't play another animations
	# That start "selected" animations
	# And doesn't give start select/unselect animations when card isn't spawned
	if not added: return
	if anim.current_animation == "spawn": return
	
	if card_holder == self:
		anim.play("selected")
		GameManager.play_sound(Res.card_apply)
		needy = 1000
		can_move = true
	else:
		anim.play("unselected")

func end_select():
	# Animation Selected 
	Events.emit_signal("card_selected", card)
	Res.erase_card(card)

func _pressed_down():
	if not _can_move_state(): return
	anim.play("selected")
# Touch outside the button
func _mouse_exited():
	if not _can_move_state(): return
	anim.play_backwards("hover")
# Touch in Button
func _mouse_entered():
	if not _can_move_state(): return
	anim.play("hover")
	GameManager.play_sound(Res.card_select)
func _can_move_state() -> bool:
	if not added: return false
	if anim.current_animation == "selected": return false
	if anim.current_animation == "unselected": return false
	if anim.current_animation == "spawn": return false
	return true
# Set pivot in Centre of all rect
func _repair_pivot():
	rect_pivot_offset = rect_size * rect_scale / 2
