extends SceneHolder
class_name GameScene

# Canvas | Display all UI
onready var canvas:CanvasLayer = $CanvasLayer
# Color Rect | A slightly hide game objects on scene
onready var  color_filler:ColorFiller = $CanvasLayer/ColorFiller
# Control Node | says to player his health exp and etc..
onready var game_control:Control = $CanvasLayer/Menu/MainContainer/GameControl
# Control Node | contains nodes when player choose new upgrade
onready var upgrade_control:Control = $CanvasLayer/Menu/MainContainer/UpgradeControl
# Control Card Node | contains card auto placement node (aka) HBox/VBox 
onready var card_holder:HBoxContainer = $CanvasLayer/Menu/MainContainer/UpgradeControl/CardsMargin/VBoxContainer/HBoxContainer
# Background | ParallaxBackGround
var background:ParallaxBackground

# --- CARDS ---
var card_to_spawn:Array = []
var _cards_to_select:bool = false
# --- STAR PATH ---
var star_path:PathSpawner

func _ready():
	Events.connect("card_selected", self, "_on_card_select")
	Res.reset_cards_out()
	_init_background()
	_init_star_map()
	_add_wave_spawner()
func _init_background():
	background = Res.background.instance()
	add_child(background)

func _init_star_map():
	star_path = Res.path_spawner.instance()
	add_child(star_path)
# Create Wave Spawner Node
func _add_wave_spawner():
	var wave_spawner = WaveSpawner.new()
	wave_spawner.name = "WaveSpawner"
	add_child(wave_spawner)
# Spawn player when game Starts | or when he has special ability to death resistance
func _spawn_main_ship(pos:Vector2):
	var unit = _spawn_unit(pos, Res.main_ship_unit)
	unit.controller_script = Res.main_ship
	if unit.controller:
		GameManager.current_point = GameManager.path_data.start_point
	unit.add()
	unit.position = pos * Difficult.get_difficult(Difficult.NORMAL).distance
	
	return unit
## Stop or Resume all children processing mode
func set_child_process(proc:bool):
	for child in get_children():
		if child is Node2D:
			child.set_physics_process(proc)
			child.set_process(proc)
# When Player select Card, and all cards animation is done, we remove all cards and resume game
func _on_card_select(card):
	_cards_to_select = false
	GameManager.add_card(card, Res.team_alien)
	_remove_cards()
	set_child_process(true)

func spawn_path(data:PathData):
	# Rescale All points
	var distance = Difficult.get_difficult(Difficult.NORMAL).distance
	GameManager.path_data = data
	var path:PathData = data.get_rescaled(distance)
	# Set Path Data to GameManager Path Data Holder variable
	_spawn_main_ship(data.start_point.pos)
# TODO: Move Add WaveSpawner.gd
func spawn_wave():
	var wave = _get_wave()

func _get_wave():
	pass

func _process(_delta):
	# Remove Star Path Node When Generation is Finished
	if star_path and star_path.finished:
		spawn_path(star_path.data)
		remove_child(star_path)
		star_path = null
	# When Player Start Selecting Cards, Spawn card with some delay
	if len(card_to_spawn) > 0:
		var card:CardHolder = card_to_spawn[0]
		if card.modulate.a == 0:
			card.spawn(1)
		if card.modulate.a > 0.69:
			card_to_spawn.erase(card)
	# CARD CATEGORY
	# We return when player exp can level up more 1 time and 
	# That fix the bug when on 3 level ups you can schoose 1 card from 6 or more
	if _cards_to_select: return
	# When EXP reach maximum level we level up and spawn cards, multiple max_expiriance by 1.2 
	# DEBUG ONLY
	if not game_control.visible: return
	if Input.is_mouse_button_pressed(1):
		var unit = _spawn_unit(get_global_mouse_position(), Res.sharp)
		unit.controller_script = Res.enemy
		unit.add()
	if Input.is_mouse_button_pressed(2):
		var unit = _spawn_unit(get_global_mouse_position(), Res.sharp)
		unit.controller_script = Res.alien
		unit.add()
	if Input.is_key_pressed(KEY_K) and GameManager.players.size() <= 1:
		var unit = _spawn_unit(get_global_mouse_position(), Res.trasher)
		unit.controller_script = Res.player
		unit.add()
		
		## Spawn unit node on given position 
func _spawn_unit(pos:Vector2, unit_folder:String = Res.unit):
	var unit:Unit = Pool.take_node(unit_folder)
	unit.velocity = Vector2.ZERO
	unit.position = pos
	unit.rotation = 0
	return unit
# Spawn cards on upgrade UI
func _spawn_cards():
	for i in 3:
		var card:CardHolder = _get_card()
		card.modulate.a = 0 # Set alpha to 0, and call spawn animation, alpha automaticly move to 0.7
		card_holder.add_child(card)
		card_to_spawn.append(card)
		
	show_upgrade_ui()
# Remove All CardHolders when player select card
func _remove_cards():
	for child in card_holder.get_children():
		if child is CardHolder:
			child.anim.stop()
			child.modulate.a = 1
		card_holder.remove_child(child)
		
	show_game_ui()
# Create CardHolder with prepared Card instance
func _get_card():
	var card:CardHolder = Pool.take_node(Res.card_holder)
	card.card = Res.drop_card()
	return card
# Show Game Screen UI and Hide others
func show_game_ui():
	game_control.visible = true
	color_filler.need_hide = true
	upgrade_control.visible = false
# Show Cards Selection UI and Hide others
func show_upgrade_ui():
	game_control.visible = false
	color_filler.need_hide = false
	upgrade_control.visible = true

func show_in_hub_ui():
	game_control.visible = false
	color_filler.need_hide = true
	upgrade_control.visible = false
