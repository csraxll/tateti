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

func _ready():
	for celda in celdas:
		celda.connect("input_event", self, "_on_TextureFrame_input_event", [celda])
		celda.connect("mouse_enter", self, "_on_TextureFrame_mouse_enter", [celda])
		celda.connect("mouse_exit", self, "_on_TextureFrame_mouse_exit", [celda])
	_restart()
	print (game_mode)
	# Called every time the node is added to the scene.
	# Initialization here
	
func _on_TextureFrame_input_event( ev , celda):
	var winner= PLAYER_NONE
	if (game_mode == GAME_MODE_1PLAYER):
		if (game_state == GAME_STATE_P1):
			if (ev.type==InputEvent.MOUSE_BUTTON and ev.pressed and logic_cells[celda.x][celda.y] == PLAYER_NONE and game_state != GAME_STATE_FINISHED):
				celda.check(game_state)
				check_count+=1
				logic_cells[celda.x][celda.y]= game_state
				game_state=  (game_state+1)%2
				_update_player_label(game_state)
				winner= _is_there_a_game()
				if (winner == PLAYER_NONE):
		#else: #IA plays...
					_ia()
					#for x in range(3):
					#	print("%d,%d,%d" % logic_cells[x])
					#print("------")
					game_state= (game_state+1)%2
					_update_player_label(game_state)
					winner= _is_there_a_game()
	if (winner != PLAYER_NONE):
		get_node("WhoPlaysControl/NowPlaysLabel").hide()
		get_node("WhoPlaysControl/WinLabel").show()
		get_node("WhoPlaysControl/RestartButtonLabel").show()
		game_state= GAME_STATE_FINISHED
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
	get_node("WhoPlaysControl/RestartButtonLabel").hide()
	for celda in celdas:
		celda.check(PLAYER_NONE)
	for x in range(3):
		for y in range(3):
			logic_cells[x][y]=PLAYER_NONE

# Hacer:
#	Aumentar prioridad de esquinas donde se pueden hacer jugadas 
#	Tener dos modos: Medio - Elige primer movimiento fuera de una esquina - Dificil - Elige primer movimiento en el medio o en una esquina
#
func _ia():
	for x in range(3):
		for y in range(3):
			ia_cells[x][y]=0
	for x in range(3):
		for y in range(3):
			if (logic_cells[x][y]==GAME_STATE_P1):
				_ia_check_ia_cell(x+1,y)
				_ia_check_ia_cell(x,y+1)
				_ia_check_ia_cell(x-1,y)
				_ia_check_ia_cell(x,y-1)
				_ia_check_ia_cell(x+2,y)
				_ia_check_ia_cell(x,y+2)
				_ia_check_ia_cell(x-2,y)
				_ia_check_ia_cell(x,y-2)
				if (_ia_cell_middle_or_corner(x,y)):
					_ia_check_ia_cell(x+1,y+1)
					_ia_check_ia_cell(x-1,y+1)
					_ia_check_ia_cell(x-1,y-1)
					_ia_check_ia_cell(x+1,y-1)
					_ia_check_ia_cell(x+2,y+2)
					_ia_check_ia_cell(x-2,y+2)
					_ia_check_ia_cell(x-2,y-2)
					_ia_check_ia_cell(x+2,y-2)
	_ia_possible_games()
	for x in range(3):
		print("%d,%d,%d" % ia_cells[x])
	print("------")
	_ia_check_cell()

func _ia_check_ia_cell(x,y):
	if (x>=0 and x <= 2 and y>=0 and y <= 2):
		if (logic_cells[x][y] == PLAYER_1 or logic_cells[x][y] == PLAYER_2):
			ia_cells[x][y]=0
		else:
			ia_cells[x][y]+=1

func _ia_cell_middle_or_corner(x,y):
	if ((x==2 and y==0) or (x==0 and y==2) or (x==y)):
		return true
	return false

func _ia_possible_games():
	for x in range(3):
		for y in range (3):
			if (logic_cells[x][y] != PLAYER_NONE and logic_cells[x][(y+1)%3] != PLAYER_NONE):
				if (logic_cells[x][y] == logic_cells[x][(y+1)%3]):
					_ia_check_ia_cell(x,(y+2)%3)
					if (logic_cells[x][y]== PLAYER_2):
						_ia_check_ia_cell(x,(y+2)%3)
				else:
					ia_cells[x][(y+2)%3]-=1
					break
	for y in range(3):
		for x in range(3):
			if (logic_cells[x][y] != PLAYER_NONE and logic_cells[(x+1)%3][y] != PLAYER_NONE):
				if (logic_cells[x][y] == logic_cells[(x+1)%3][y]):
					_ia_check_ia_cell((x+2)%3,y)
					if (logic_cells[x][y]== PLAYER_2):
						_ia_check_ia_cell((x+2)%3,y)
				else:
					ia_cells[(x+2)%3][y]-=1
					break
	for i in range(3):
		if (logic_cells[i][i] != PLAYER_NONE and logic_cells[(i+1)%3][(i+1)%3] != PLAYER_NONE):
			if (logic_cells[i][i] == logic_cells[(i+1)%3][(i+1)%3]):
				_ia_check_ia_cell((i+2)%3,(i+2)%3)
				if (logic_cells[i][i]== PLAYER_2):
					_ia_check_ia_cell((i+2)%3,(i+2)%3)
			else:
				ia_cells[(i+2)%3][(i+2)%3]-=1
				break
	if (logic_cells[2][0] != PLAYER_NONE and logic_cells[1][1] != PLAYER_NONE):
		if (logic_cells[2][0] == logic_cells[1][1]):
			_ia_check_ia_cell(0,2)
			if (logic_cells[2][0] == PLAYER_2):
				_ia_check_ia_cell(0,2)
		else:
			ia_cells[0][2]-=1
	
	if (logic_cells[1][1] != PLAYER_NONE and logic_cells[0][2] != PLAYER_NONE):
		if (logic_cells[1][1] == logic_cells[0][2]):
			_ia_check_ia_cell(2,0)
			if (logic_cells[1][1] == PLAYER_2):
				_ia_check_ia_cell(2,0)
		else:
			ia_cells[2][0]-=1
			
	if (logic_cells[0][2] != PLAYER_NONE and logic_cells[2][0] != PLAYER_NONE):
		if (logic_cells[0][2] == logic_cells[2][0]):
			_ia_check_ia_cell(1,1)
			if (logic_cells[0][2] == PLAYER_2):
				_ia_check_ia_cell(1,1)
		else:
			ia_cells[1][1]-=1
#	for i in range(3):
#		if (logic_cells[(i+2)%3][i] != PLAYER_NONE and logic_cells[(i+1)%3][(i+1)%3] != PLAYER_NONE):
#			if (logic_cells[(i+2)%3][i] == logic_cells[(i+1)%3][(i+1)%3]):
#				_ia_check_ia_cell(i,(i+2)%3)
#				if (logic_cells[(i+2)%3][i] == PLAYER_2):
#					_ia_check_ia_cell(i,(i+2)%3)
#			else:
#				ia_cells[i][(i+2)%3]-=1
#				break

func _ia_check_cell():
	var best_options = []
	var index
	var max_priority= 0
	for x in range(3):
		for y in range (3):
			if (ia_cells[x][y] == max_priority):
				best_options.append(Vector2(x,y))
			elif(ia_cells[x][y] > max_priority):
				best_options.clear()
				best_options.append(Vector2(x,y))
				max_priority= ia_cells[x][y]
	randomize()
	var i=randi() % best_options.size()
	logic_cells[best_options[i].x][best_options[i].y] = game_state
	for celda in celdas:
		if (celda.x== best_options[i].x and celda.y== best_options[i].y):
			celda.check(game_state)
	
				
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

func _on_RestartButtonLabel_input_event( ev ):
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.pressed):
		_restart()
	
func _on_BackButtonLabel_input_event( ev ):
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.pressed):
		get_tree().change_scene("res://title_menu.tscn")
