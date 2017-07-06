extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("mouse_enter",self,"_mouse_enter")
	connect("mouse_exit",self,"_mouse_exit")

func _mouse_enter():
	add_color_override("font_color", Color(0.621094,0.59198,0.59198))
	
func _mouse_exit():
	add_color_override("font_color", Color(0.317647,0.392157,0.678431))