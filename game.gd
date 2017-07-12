extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
enum {GAME_STATE_P1, GAME_STATE_P2, GAME_STATE_FINISHED}
enum {GAME_MODE_1PLAYER, GAME_MODE_2PLAYER}
enum {PLAYER_1, PLAYER_2, PLAYER_NONE}

var logic_cells =[ [PLAYER_NONE,PLAYER_NONE,PLAYER_NONE],
				   [PLAYER_NONE,PLAYER_NONE,PLAYER_NONE],
				   [PLAYER_NONE,PLAYER_NONE,PLAYER_NONE] ]
var ia_cells =[ [0,0,0],
				[0,0,0],
				[0,0,0] ]
				
var game_state= GAME_STATE_P1
var game_mode = Globals.get("GAME_MODE")
var check_count=0
var wins_player1=0
var wins_player2=0
var textMainColor= Color(0.321259,0.394064,0.679688)
onready var celdas = get_node("GridContainer").get_children()
onready var playerLabel = get_node("WhoPlaysControl/PlayerLabel")
onready var nowPlaysLabel = get_node("WhoPlaysControl/NowPlaysLabel")
onready var winLabel =get_node("WhoPlaysControl/WinLabel")
onready var tieLabel = get_node("WhoPlaysControl/TieLabel")
onready var restartButtonLabel = get_node("WhoPlaysControl/RestartButtonLabel")
						
func _ready():
	for celda in celdas:
		celda.connect("input_event", self, "_on_TextureFrame_input_event", [celda])
		celda.connect("mouse_enter", self, "_on_TextureFrame_mouse_enter", [celda])
		celda.connect("mouse_exit", self, "_on_TextureFrame_mouse_exit", [celda])
	_restart()
	#print (game_mode)
	# Called every time the node is added to the scene.
	# Initialization here
	
func _on_TextureFrame_input_event( ev , celda):
	var j
	if (game_state == GAME_STATE_P1 or game_state == GAME_STATE_P2):
		if (ev.type==InputEvent.MOUSE_BUTTON and ev.pressed and logic_cells[celda.x][celda.y] == PLAYER_NONE):
			logic_cells[celda.x][celda.y]= game_state
			celda.check(game_state)
			check_count+=1
			print("hola")
			if (_is_there_a_game(game_state) or check_count == 9):
				game_state= GAME_STATE_FINISHED
			else:
				game_state= (game_state+1)%2
				_update_player_label(game_state)
		if (game_mode == GAME_MODE_1PLAYER):
			if (game_state == GAME_STATE_P2):
				print("chau")
				get_node("Timer").start()
				yield(get_node("Timer"), "timeout")
				_ia()
				check_count+=1
				if (_is_there_a_game(PLAYER_2) or check_count == 9):
					game_state= GAME_STATE_FINISHED
				else:
					game_state= GAME_STATE_P1
					_update_player_label(game_state)
					yield(playerLabel, "draw")
		if (game_state== GAME_STATE_FINISHED):
			nowPlaysLabel.hide()
			restartButtonLabel.show()
			if (_is_there_a_game(PLAYER_1) or _is_there_a_game(PLAYER_2)):
				winLabel.show()
				tieLabel.hide()
			else:
				_update_player_label(game_state)
				#yield(playerLabel, "draw")
				winLabel.hide()
				tieLabel.show()
				
	#print(check_count)
		
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
	nowPlaysLabel.show()
	winLabel.hide()
	tieLabel.hide()
	restartButtonLabel.hide()
	playerLabel.show()
	for celda in celdas:
		celda.check(PLAYER_NONE)
	for x in range(3):
		for y in range(3):
			logic_cells[x][y]=PLAYER_NONE

func _ia():
	var max_value= -9999
	var x_selected=1
	var y_selected=1
	var value= -9999
	for x in range(3):
		for y in range(3):
			if (logic_cells[x][y] == PLAYER_NONE):
				logic_cells[x][y] = PLAYER_2
				value= _ia_minimize_game()
				if (value > max_value):
					max_value = value
					x_selected= x
					y_selected= y
				logic_cells[x][y] = PLAYER_NONE
	logic_cells[x_selected][y_selected] = PLAYER_2
	for celda in celdas:
		if (celda.x== x_selected and celda.y== y_selected):
			celda.check(PLAYER_2)

func _ia_minimize_game():
	if (_is_there_a_game(PLAYER_2)):
		return 1
	if (_ia_are_all_cells_checked()):
		return 0
	var min_value= 9999
	var value= 9999
	for x in range(3):
		for y in range(3):
			if (logic_cells[x][y] == PLAYER_NONE):
				logic_cells[x][y] = PLAYER_1
				value = _ia_maximize_game()
				if (value < min_value):
					min_value = value
				logic_cells[x][y] = PLAYER_NONE
	return min_value
		
		
func _ia_maximize_game():
	if (_is_there_a_game(PLAYER_1)):
		return (-1)
	if (_ia_are_all_cells_checked()):
		return 0
	var max_value= (-9999)
	var value = (-9999)
	for x in range(3):
		for y in range(3):
			if (logic_cells[x][y] == PLAYER_NONE):
				logic_cells[x][y] = PLAYER_2
				value = _ia_minimize_game()
				if (value > max_value):
					max_value = value
				logic_cells[x][y] = PLAYER_NONE
	return max_value

func _ia_are_all_cells_checked():
	for x in range(3):
		for y in range(3):
			if (logic_cells[x][y] == PLAYER_NONE):
				return false
	return true

func _ia_is_cell_empty(x,y):
	if (logic_cells[x][y] == PLAYER_NONE):
		return true
	return false

func _ia_check_ia_cell(x,y,player):
	if (x>=0 and x <= 2 and y>=0 and y <= 2):
		logic_cells[x][y]= player

func _ia_cell_middle_or_corner(x,y):
	if ((x==2 and y==0) or (x==0 and y==2) or (x==y)):
		return true
	return false

func _ia_check_cell(x,y):
	logic_cells[x][y] = PLAYER_2
	for celda in celdas:
		if (celda.x== x and celda.y== y):
			celda.check(PLAYER_2)
	
				
func _is_there_a_game(player):
	var boolean = (logic_cells[0][0] == player and logic_cells[0][1] == player and logic_cells[0][2] == player )
	boolean = boolean || (logic_cells[1][0] == player and logic_cells[1][1] == player and logic_cells[1][2] == player )
	boolean = boolean || (logic_cells[2][0] == player and logic_cells[2][1] == player and logic_cells[2][2] == player )
	
	boolean = boolean || (logic_cells[0][0] == player and logic_cells[1][0] == player and logic_cells[2][0] == player )
	boolean = boolean || (logic_cells[0][1] == player and logic_cells[1][1] == player and logic_cells[2][1] == player )
	boolean = boolean || (logic_cells[0][2] == player and logic_cells[1][2] == player and logic_cells[2][2] == player )
	
	boolean = boolean || (logic_cells[0][0] == player and logic_cells[1][1] == player and logic_cells[2][2] == player )
	boolean = boolean || (logic_cells[2][0] == player and logic_cells[1][1] == player and logic_cells[0][2] == player )
	return boolean
	
func _update_player_label(player):
	if (player == GAME_STATE_P1):
		playerLabel.set_text("Jugador 1")
		playerLabel.add_color_override("font_color", Color(0.867188,0.165985,0.165985))
		playerLabel.update()
	elif (player == GAME_STATE_P2):
		playerLabel.set_text("Jugador 2")
		playerLabel.add_color_override("font_color", Color(0.270676,0.631152,0.949219))
		playerLabel.update()
	else:
		playerLabel.hide()

func _on_RestartButtonLabel_input_event( ev ):
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.pressed):
		_restart()
	
func _on_BackButtonLabel_input_event( ev ):
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.pressed):
		get_tree().change_scene("res://title_menu.tscn")
