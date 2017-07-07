extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
enum {GAME_MODE_1PLAYER, GAME_MODE_2PLAYER}

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	
func _on_1PlayerButtonLabel_input_event( ev ):
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.pressed):
		Globals.set("GAME_MODE",GAME_MODE_1PLAYER)
		get_tree().change_scene("res://game.tscn")
		
		
func _on_2PlayersButtonLabel_input_event( ev ):
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.pressed):
		Globals.set("GAME_MODE",GAME_MODE_2PLAYER)
		get_tree().change_scene("res://game.tscn")