extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
enum {STATE_1,STATE_2}
enum {GAME_STATE_P1, GAME_STATE_P2, GAME_STATE_FINISHED}
enum {PLAYER_1, PLAYER_2, PLAYER_NONE}

var label1_state=STATE_1
var label2_state=STATE_1

var label1_messages = ["L1 Estado 1","L1 Estado 2"]
var label2_messages = ["L2 Estado 1","L2 Estado 2"]

var logic_cells =[ [PLAYER_NONE,PLAYER_NONE,PLAYER_NONE],
				   [PLAYER_NONE,PLAYER_NONE,PLAYER_NONE],
				   [PLAYER_NONE,PLAYER_NONE,PLAYER_NONE] ]
				
var game_state= GAME_STATE_P1
var check_count=0
onready var celdas = get_node("GridContainer").get_children()
onready var playerLabel = get_node("WhoPlaysControl/PlayerLabel")

func _ready():
	for celda in celdas:
		celda.connect("input_event", self, "_on_TextureFrame_input_event", [celda])
		celda.connect("mouse_enter", self, "_on_TextureFrame_mouse_enter", [celda])
		celda.connect("mouse_exit", self, "_on_TextureFrame_mouse_exit", [celda])
	_restart()
	# Called every time the node is added to the scene.
	# Initialization here
	
func _on_TextureButton_button_down_1():
	label2_state = (label2_state+1) % 2 
	get_node("Panel 2/Label").set_text(label2_messages[label2_state])
	
func _on_TextureButton_button_down_2():
	label1_state = (label1_state+1) % 2 
	get_node("Panel/Label").set_text(label1_messages[label1_state])


func _on_TextureFrame_input_event( ev , celda):
	var winner= PLAYER_NONE
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.pressed):
		celda.check(game_state)
		check_count+=1
		logic_cells[celda.x][celda.y]= game_state
		game_state=  (game_state+1)%2
		_update_player_label(game_state)
		winner= _is_there_a_game()
		
	if (winner != PLAYER_NONE):
		get_node("WhoPlaysControl/NowPlaysLabel").hide()
		get_node("WhoPlaysControl/WinLabel").show()
		get_node("WhoPlaysControl/QuitButton").show()
		_update_player_label(winner)
	if (check_count>=9):
		_restart()
		
func _on_TextureFrame_mouse_enter(celda):
	if (logic_cells[celda.x][celda.y] == PLAYER_NONE):
		celda.preCheck(game_state)
	
func _on_TextureFrame_mouse_exit(celda):
	if (logic_cells[celda.x][celda.y] == PLAYER_NONE):
		celda.preCheck(null)
	
func _restart():
	game_state= GAME_STATE_P1
	check_count=0
	playerLabel.set_text("Jugador 1")
	playerLabel.add_color_override("font_color", Color(0.867188,0.165985,0.165985))
	get_node("WhoPlaysControl/NowPlaysLabel").show()
	get_node("WhoPlaysControl/WinLabel").hide()
	get_node("WhoPlaysControl/QuitButton").hide()
	for celda in celdas:
		celda.check(PLAYER_NONE)
	for x in range(3):
		for y in range(3):
			logic_cells[x][y]=PLAYER_NONE
		
func _is_there_a_game():
	for x in range(3):
		if (logic_cells[x][0] !=PLAYER_NONE and logic_cells[x][0] == logic_cells[x][1] and logic_cells[x][1] == logic_cells[x][2] ):
			return logic_cells[x][0]
	for y in range(3):
		if (logic_cells[0][y] !=PLAYER_NONE and logic_cells[0][y] == logic_cells[1][y] and logic_cells[1][y] == logic_cells[2][y] ):
			return logic_cells[0][y]
	if (logic_cells[1][1] != PLAYER_NONE):
		if (logic_cells[0][0] == logic_cells[1][1] and logic_cells[1][1] == logic_cells[2][2]):
			return logic_cells[1][1]
		if (logic_cells[2][0] == logic_cells[1][1] and logic_cells[1][1] == logic_cells[0][2]):
			return logic_cells[1][1]
	return PLAYER_NONE
	
func _update_player_label(player):
	if (player == GAME_STATE_P1):
		playerLabel.set_text("Jugador 1")
		playerLabel.add_color_override("font_color", Color(0.867188,0.165985,0.165985))
	else:
		playerLabel.set_text("Jugador 2")
		playerLabel.add_color_override("font_color", Color(0.270676,0.631152,0.949219))