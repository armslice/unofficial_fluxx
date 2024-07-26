extends Node2D

enum CARD_TYPE {GOAL,RULE,ACTION,KEEPER}

@export var card_name: String = ""
@export var type: CARD_TYPE

func _ready():
	$face.material = $face.material.duplicate()
	
func set_card():
	#setColor
	match type:
		CARD_TYPE.GOAL:
			set_color(Color.WEB_PURPLE)
		CARD_TYPE.RULE:
			set_color(Color.GOLD)
		CARD_TYPE.ACTION:
			set_color(Color.DEEP_SKY_BLUE)
		CARD_TYPE.KEEPER:
			set_color(Color.GREEN)

func set_color(color:Color):
	$face.material.set_shader_param("card_color",color)
