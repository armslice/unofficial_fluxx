extends Resource

class_name CardDefinition

@export var id : String
@export_multiline var title : String
@export_multiline var subtitle : String
@export_multiline var description : String
@export var type : ref.TYPE
@export var values : Array



func setup():
	if title == "":
		title = id


func getRuleType():
	match id:
		"Draw 2","Draw 3","Draw 4" ,"Draw 5":
			return ref.RULE_TYPE.DRAW
		"Hand Limit 0","Hand Limit 1","Hand Limit 2":
			return ref.RULE_TYPE.H_LIMIT
		"Play 2","Play 3","Play 4","Play All","Play All But 1":
			return ref.RULE_TYPE.PLAY
		"Keeper Limit 2","Keeper Limit 3","Keeper Limit 4":
			return ref.RULE_TYPE.K_LIMIT
		"No-Hand Bonus","Double Agenda","Poor Bonus","Rich Bonus","Party Bonus","Inflation","First Play Random":
			return ref.RULE_TYPE.OTHER
		"Mystery Play","Recycling","Swap Plays for Draws","Goal Mill","Get On With It!":
			return ref.RULE_TYPE.FREE_ACTION
