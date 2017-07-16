extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var mainColor
var hoverColor
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	connect("mouse_enter",self,"_mouse_enter")
	connect("mouse_exit",self,"_mouse_exit")
	mainColor= get_node("/root/global").textMainColor;
	hoverColor= get_node("/root/global").textHoverColor;

func _mouse_enter():
	add_color_override("font_color", hoverColor)
	
func _mouse_exit():
	add_color_override("font_color", mainColor)