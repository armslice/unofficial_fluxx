extends Node

enum TYPE {GOAL,RULE,ACTION,KEEPER}

enum RULE_TYPE {NONE,DRAW,PLAY,H_LIMIT,K_LIMIT,FREE_ACTION,OTHER}

@onready var card = preload("res://Card.tscn")
@onready var miniKeeper = preload("res://miniKeeper.tscn")

var board
var game

func tween(node,prop,end,time=1.0,delay=0,trans=Tween.TRANS_LINEAR):
	var t = get_tree().create_tween()
	if delay > 0:
		t.tween_interval(delay)
	t.set_trans(trans)
	t.tween_property(node, prop, end, time)
	return t
	
func folderForCard(id):
	match id:
		"The Party","Cookies","Milk","The Eye","The Sun","The Brain","The Moon","Chocolate","Dreams","Time","Sleep","Music","The Toaster","Money","The Rocket","Television","Bread","Love","Peace":
			return "keepers"
		"Lullaby","Can’t Buy Me Love","Rocket Science","Party Time!","Time is Money","Milk & Cookies","Rocket to the Moon","Baked Goods","Winning the Lottery","The Brain (No TV)","10 Cards in Hand","Chocolate Cookies","Toast","Turn Up the Volume!","Party Snacks","Night & Day","Hippyism","Dreamland","The Appliances","The Mind’s Eye","Hearts & Minds","Bread & Chocolate","5 Keepers","Squishy Chocolate","World Peace","Chocolate Milk","Bed Time","Beauty","Day Dreams","Great Theme Song":
			return "goals"
		"Draw 2","Draw 3","Draw 4","Draw 5","Hand Limit 0","Hand Limit 1","Hand Limit 2","Play 2","Play 3","Play 4","Play All","Play All But 1","Keeper Limit 2","Keeper Limit 3","Keeper Limit 4","No-Hand Bonus","Double Agenda","Poor Bonus","Rich Bonus","Party Bonus","Mystery Play","Recycling","Inflation","First Play Random","Swap Plays for Draws","Goal Mill","Get On With It!":
			return "rules"
		"Exchange Keepers","Draw 2 and Use ‘Em","Today’s Special!","Let’s Do That Again!","Random Tax","Use What You Take","Trash A New Rule","Let’s Simplify","Draw 3, Play 2 of Them","Jackpot!","Trade Hands","Discard and Draw","Rules Reset","Trash a Keeper","Everybody Gets 1","Steal a Keeper","Empty the Trash","Share the Wealth","Take Another Turn","No Limits","Rotate Hands","Zap a Card","RPS Showdown":
			return "actions"
