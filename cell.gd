extends TextureFrame

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
enum {PLAYER_1, PLAYER_2, PLAYER_NONE}
var texture_blank= preload("res://assets/buttons/button_blank.png")
var texture_cross= preload("res://assets/buttons/button_cross.png")
var texture_circle= preload("res://assets/buttons/button_circle.png")

var texture_cross_pre= preload("res://assets/buttons/button_cross_pre.png")
var texture_circle_pre= preload("res://assets/buttons/button_circle_pre.png")

export var x=0
export var y=0
func _ready():
	self.set_texture(texture_blank);
	
func check(player):
	if (player==PLAYER_1):
		self.set_texture(texture_cross)
	elif (player==PLAYER_2):
		self.set_texture(texture_circle)
	else:
		self.set_texture(texture_blank)
		
func preCheck(player):
	if (player==PLAYER_1):
		self.set_texture(texture_cross_pre)
	elif (player==PLAYER_2):
		self.set_texture(texture_circle_pre)
	else:
		self.set_texture(texture_blank)