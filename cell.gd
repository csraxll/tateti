extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
enum {PLAYER_1, PLAYER_2, PLAYER_NONE}

export var x=0
export var y=0

onready var sprite = get_node("AnimatedSprite")

func _ready():
	#sprite.hide()
	sprite.set_animation("empty_mark")

func _draw():
	pass

func check(player):
	if (player==PLAYER_1):
	#	sprite.show()
		sprite.set_animation("cross_mark")
	elif (player==PLAYER_2):
	#	sprite.show()
		sprite.set_animation("circle_mark")
	else:
		sprite.set_animation("empty_mark")
		
func preCheck(player):
	if (player==PLAYER_1):
		sprite.set_animation("empty_mark")
	elif (player==PLAYER_2):
		sprite.set_animation("empty_mark")
	else:
		sprite.set_animation("empty_mark")