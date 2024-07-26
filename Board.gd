extends Node2D

enum {CARD_IDS,CARD_DEFS}

const TYPE_ORDER = ["keepers","goals","actions","rules"]

var active = false

var allCards = []
var deck = []
var discardPile = []
var discardTop = null
var currentPlayer = 0

var goals = []

var rules = {ref.RULE_TYPE.DRAW:null,
ref.RULE_TYPE.PLAY:null,
ref.RULE_TYPE.H_LIMIT:null,
ref.RULE_TYPE.K_LIMIT:null,
ref.RULE_TYPE.OTHER: [],
ref.RULE_TYPE.FREE_ACTION: []}

var ruleFlags = {
	"Inflation": false,
	"Draw": 1,
	"Play": 1,
	"Hand": -1,
	"Rich Bonus":false,
	"Poor Bonus":false,
	"Double Agenda":false
	
}

var keeperLimit = null


const topPositionAtFull = -184
const CARD_ZONE_W = 500
const CARD_W = 400
const CARD_H = 625

var highlightCard = null
var highlightsPlayed = []
var dragCard = null
var dropZone = null
var mouseOverHand =false
var ruleZoom = false
var playerView = false

@onready var handPos = $HandPos.position
@onready var dropper = $dropper
@onready var playerDock = $PlayerDock

var topPositionOfDeck = 0

var mainPlayerNumber = 0
var players = []


class Player:
	var number
	var name
	var hand = []
	var keepers = []
	var plays = 0
	var draws = 99
	var dockSlot
	
	func _init(num):
		self.number = num
	
	func _to_string():
		var handStr = "Hand : ["
		for i in hand.size():
			handStr += "%s: %s, "%[i,hand[i]]
		handStr = handStr.substr(0,handStr.length()-2) + "]"
		return "P%s %s %s keepers: %s plays: %s draws: %s dock #: %s"%[number, name, handStr, keepers, plays, draws, dockSlot]

func _ready():
	dropper.visible= false
	ref.board = self
	$Message.scale = Vector2(1,0)
	$Message/Panel/Label.text = ""
	for t in ref.TYPE:
		highlightsPlayed.append(null)

	
		
func _process(delta):
	if ref.game.dev:
		ref.game.debug("HighLightCard: %s \nDragCard: %s\nDropZone: %s\nRules: %s\nRuleFlags: %s"%[
			highlightCard,dragCard,dropZone,rules,ruleFlags])
		for p in players:
			ref.game.debug("\n%s"%p)
	
	if dragCard:
		dragCard.position = get_global_mouse_position()-dragCard.mouseOffset
	mouse()

func testMatch():
		await(get_tree().create_timer(1).timeout)
		showMessage("This is a test match",2)
		
		deck = getFullDeck(CARD_DEFS)
		setDeckHeight(deck.size())
		deck.shuffle()	
	
		for i in 4:
			var p = Player.new(i)
			p.name = "Player %s"%(i+1)
			p.dockSlot = i-1
			players.append(p)
			if p.dockSlot >=0:
				playerDock.setSlotPlayer(p.dockSlot,p)
		
#		for i in 12:
#			drawCard(i%4)
#			await get_tree().create_timer(.5).timeout
		
		active = true
	

func mouse():
	if not active:
		return
	var mPos = get_global_mouse_position()
	

	if Input.is_action_just_pressed("mouse"):
		if highlightCard:
			highlightCard.on_mouse_down()
	if Input.is_action_just_released("mouse"):
		if dragCard:
			dropCard()
				
	if mouseOverHand and not dragCard:
		if hand().is_empty():
			return
		for c in hand():
			c.distanceToMouse = c.position.distance_to(mPos)
		var hCard = hand().reduce(func(max,card):
			return card if card.distanceToMouse < max.distanceToMouse else max
			,hand()[0])
		if hCard.distanceToMouse < CARD_H*.6:
			highlight(hCard)
		elif highlightCard:
			removeHighlight(highlightCard)
		
	if highlightCard and not mouseOverHand and not dragCard:
		removeHighlight(highlightCard)

func showMessage(txt,time):
	$Message/Panel/Label.text = txt
	(await ref.tween($Message,"scale",Vector2(1,1),.5,0,Tween.TRANS_EXPO)).tween_callback(func():
		ref.tween($Message,"scale",Vector2(1,0),.5,time,Tween.TRANS_EXPO))

func setDeckHeight(h):
	topPositionOfDeck = topPositionAtFull * h/99.0
	$Deck/top.position.y = topPositionOfDeck

func getFullDeck(cardsEnum):
	var list = []
	for folder in TYPE_ORDER:
		var dir = DirAccess.open("res://cardDefs/%s"%folder)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				match cardsEnum:
					CARD_IDS:
						list.append(file_name.substr(0,-4))
					CARD_DEFS:
						list.append(ResourceLoader.load("res://cardDefs/%s/%s"%[folder,file_name]))
				file_name = dir.get_next()
		else:
			print("An error occurred when trying to access the path.")
	return list	
	
func getCardDef(id):
	return ResourceLoader.load("res://cardDefs/%s/%s"%[ref.folderForCard(id),"%s.tres"%id])

func drawCard(playerNumber, times = 1):
	var card = ref.card.instantiate()
	
	#replace with get card definition from stack on server
	card.def = deck.pop_back()
#	print("Card title is empty  ",card.def.title=="")
	card.setCard()
	
	card.position = $Deck.position + Vector2(0,topPositionOfDeck)
	add_child(card)
		
	if deck.size() == 0:
		$Deck.visible = false
	setDeckHeight(deck.size())
	
	if playerNumber == mainPlayerNumber:
		card.deal(true)
		
		var hand = players[mainPlayerNumber].hand
		card.slot = hand.size()
		hand.append(card)
		layoutPlayerCards(false)
		var space = min(CARD_ZONE_W/hand.size(),CARD_W*.6)
		var t = await ref.tween(card,"position",cardPlaceForSpaceAtI(space,hand.size()-1),1)
		t.tween_callback(func():
			card.grabable = true)
	else:
		card.slot = players[playerNumber].hand.size()
		players[playerNumber].hand.append(card)
		playerDock.update(players[playerNumber].dockSlot)
		card.z_index = 150
		card.deal()
		var t = await ref.tween(card,"position",getDockPosition(playerNumber),1)
		t.tween_callback(func():
			remove_child(card))
	if times>1:
		await get_tree().create_timer(.5).timeout
		drawCard(playerNumber,times-1)

func takeTurn(playerNumber):
	currentPlayer = playerNumber
	drawCard(playerNumber,getDraws(playerNumber))
	players[playerNumber].plays = getPlays(playerNumber)
	playerDock.update(players[playerNumber].dockSlot)

func cardPlaceForSpaceAtI(space,i):
	return Vector2(i*space+handPos.x,handPos.y)
			

func getDockPosition(playerNumber):	
	return playerDock.get_node("p%s/info/cardIcon/cardSpot"%players[playerNumber].dockSlot).global_position


func mouseEnterCard(card):
	if dragCard and card.isDropzone and not dragCard == card:
		dropZone = card
	if card.played:
#		if card.def.type == ref.TYPE.GOAL or [ref.RULE_TYPE.OTHER,ref.RULE_TYPE.FREE_ACTION].has(card.def.getRuleType()):
		var highlighted = highlightsPlayed[card.def.type]
		if highlighted == card:
			return
		if highlighted:
			highlighted.z_index = highlighted.prevZ
		card.prevZ = card.z_index
		card.z_index = 110
		highlightsPlayed[card.def.type] = card
			
	
func mouseExitCard(card):
	if dragCard:
		if dropZone and typeof(dropZone) == TYPE_OBJECT and dropZone == card:
			dropZone = null
	
func highlight(card):
#	for c in hand():
#		if not c == card:
#			c.active(false)
	if highlightCard and not card == highlightCard:
		highlightCard.highlight(false)
	if not card == highlightCard:
		highlightCard = card
		card.highlight(true)

func removeHighlight(card):
	if highlightCard == card:
		card.highlight(false)
		highlightCard = null
#		for c in hand():
#			c.active(true)
		

func playCard(playerNumber: int, card):
	if players[playerNumber].plays < 1:
		return
	players[playerNumber].plays -=1
	if typeof(card) == TYPE_INT:
		if card >= players[playerNumber].hand.size():
			printerr("Play card index out of bounds : Player # %s Index: %s"%[playerNumber,card])
			return
		card = players[playerNumber].hand[card]
	card.z_index = 101
	removeCard(playerNumber,card)
	card.play()
	if playerNumber!=mainPlayerNumber and not card.def.type == ref.TYPE.KEEPER:
		await otherPlayerPlaysCard(playerNumber,card).timeout
	
	match card.def.type:
		ref.TYPE.GOAL:
			addGoal(card)
		ref.TYPE.KEEPER:
			addKeeper(playerNumber,card)
		ref.TYPE.ACTION:
			playAction(card)
		ref.TYPE.RULE:
			playRule(card)
			
	if playerNumber != mainPlayerNumber:
		playerDock.update(players[playerNumber].dockSlot)
		

func otherPlayerPlaysCard(playerNumber,card,callback =null, delay = 0):
	card.position= getDockPosition(playerNumber)
	card.scale = Vector2(0,0)
	add_child(card)
	card.reveal()
	var t = create_tween().set_parallel(true)
	t.tween_property(card,"scale",Vector2(.6,.6),.7)
	t.tween_property(card,"position",card.position+Vector2(0,365),.7)
	if callback:
		t.chain().tween_callback(callback).set_delay(delay)
	return get_tree().create_timer(.7)

func addGoal(card: Card, replace= 0):
	card.scaleTo(.5)
	var goalLimit = 2 if ruleFlags["Double Agenda"] else 1
	if goals.size() < goalLimit:
		goals.append(card)
	else:
		var discarded = goals[replace]
		discard(discarded)
		goals[replace] = card
	var spot = $goalSpot.position
	if goals.size()>1:
		for i in goals.size():
			moveTo(goals[i],spot-Vector2((CARD_W/goals.size())*i/3.0,0),.5)
	else:
		moveTo(card,$goalSpot.position,.5)
	
func addKeeper(playerNumber,card):
	if playerNumber == mainPlayerNumber:
		if keeperLimit:
			#wait for selection the keeper to replace
			pass
		mainPlayer().keepers.append(card)
		(await moveTo(card,$keeperSpot.position,.5)).tween_callback(func():
			layoutKeepers(mainPlayerNumber))
	else:
		players[playerNumber].keepers.append(card)
		otherPlayerPlaysCard(playerNumber,card,func():
				layoutKeepers(playerNumber),1)
				
#		card.position= getDockPosition(playerNumber)
#		card.scale = Vector2(0,0)
#		add_child(card)
#		card.reveal()
#		var t = create_tween().set_parallel(true)
#		t.tween_property(card,"scale",Vector2(.6,.6),.7)
#		t.tween_property(card,"position",card.position+Vector2(0,365),.7)
#		t.chain().tween_callback(func():
#				layoutKeepers(playerNumber)).set_delay(1)
		
		playerDock.playKeeper(players[playerNumber].dockSlot,card.def.id)


func playAction(card):
	card.scaleTo(1)
	card.z_index = 110
	(await moveTo(card,$actionSpot.position,.5)).tween_callback(func():
		#doaction
		await get_tree().create_timer(3).timeout
		discard(card))
		
func playRule(card):
	card.scaleTo(.5)
	var pos
	var t = card.def.getRuleType()
	match t:
		ref.RULE_TYPE.H_LIMIT:
			pos = $limitRulesSpot.position - Vector2((CARD_W*.5)/2-2,0)
		ref.RULE_TYPE.K_LIMIT:
			pos =  $limitRulesSpot.position + Vector2((CARD_W*.5)/2-2,0)
		ref.RULE_TYPE.DRAW:
			pos = $drawRuleSpot.position
		ref.RULE_TYPE.PLAY:
			pos = $playRuleSpot.position
		ref.RULE_TYPE.OTHER:
			pos = $otherRulesSpot.position
		ref.RULE_TYPE.FREE_ACTION:
			pos = $freeActionRulesSpot.position
			
			
	setRule(t,card)
	moveTo(card,pos,.5)
	if [ref.RULE_TYPE.OTHER,ref.RULE_TYPE.FREE_ACTION].has(t):
		layoutRules()
	

func setRule(type,card,active = true):
	if [ref.RULE_TYPE.OTHER,ref.RULE_TYPE.FREE_ACTION].has(type):
		rules[type].append(card)
	else:
		if rules[type]:
			discard(rules[type])
		rules[type] = card
	var id = card.def.id
	match id:
		"Inflation","Poor Bonus","Rich Bonus": 
			ruleFlags[id] = active
	
	var prefix = id.substr(0,4)
	match prefix:
		"Draw","Play","Hand":
			ruleFlags[prefix] = card.def.values[0]
				
			
			
func layoutPlayerCards(includeLast=true):
	var hand = players[mainPlayerNumber].hand
	if hand.is_empty():
		return
	var space = min(CARD_ZONE_W/hand.size(),CARD_W)
	for i in hand.size():
		if hand[i].highlighted:
			continue
		hand[i].slot = i
		hand[i].z_index = 10+i
		if not includeLast and i == hand.size()-1:
			return
		ref.tween(hand[i],"position",cardPlaceForSpaceAtI(space,i),.5)

func layoutKeepers(playerNumber):
	const KEEPERS_W = 475
	var count = players[playerNumber].keepers.size()
	var scaling = .5
	var rows = 1
	var space = CARD_W*scaling
	
	if count > 8:
		space = KEEPERS_W/count
	elif count > 3:
		rows = 2
		scaling = .35
		space = CARD_W*scaling
		
#	elif count ==4:
#		scaling = .45
#		space = CARD_W*scaling
	var spot
	if playerNumber==mainPlayerNumber:
		spot = $keeperSpot.position
	else:
		spot = playerDock.keeperPosition(players[playerNumber].dockSlot)
		
	var rowLen = int(ceil(count/float(rows)))
	var none = null
	for i in count:
		var card = players[playerNumber].keepers[i]
		var x = (i%rowLen)*space
		var y = 0
		if rows > 1:
			y = - ((int(i/rowLen))*(CARD_H*scaling))
		var speed = .3 if playerNumber==mainPlayerNumber else 1
		(await moveTo(card,Vector2(x,y)+spot,.3)).tween_callback(func():
			card.scaleTo(scaling))
		card.z_index = 20+i

func layoutRules():
	const RULE_W = 325
	for type in [ref.RULE_TYPE.OTHER,ref.RULE_TYPE.FREE_ACTION]:
		if not rules[type].is_empty():
			var space = min(RULE_W/rules[type].size(),CARD_W*1.5)
			var spot = ($otherRulesSpot if type == ref.RULE_TYPE.OTHER else $freeActionRulesSpot).position
			for i in rules[type].size():
				moveTo(rules[type][i],spot+Vector2(i*space,0),.5)
				rules[type][i].z_index = 10+i
		
func discard(card):
	card.played = false
	if highlightsPlayed[card.def.type] == card:
		highlightsPlayed[card.def.type] = null
	card.z_index = discardPile.size()+10
	(await moveTo(card, $discardSpot.position - Vector2(0,discardPile.size()),.5)).tween_callback(func():
		card.scaleTo(.5)
		if discardTop:
			discardTop.queue_free()
		discardTop = card
		discardPile.append(card.def)
		if discardPile.size() == 1:
			$discardSpot/stack.visible = true
		)

func removeCard(playerNumber,card):
	players[playerNumber].hand.remove_at(card.slot)
	for i in players[playerNumber].hand.size():
		players[playerNumber].hand[i].slot = i	

func grabCard(card):
	dragCard = card
	remove_child(dropper)
	card.add_child(dropper)
	dropper.visible = true
	

func dropCard():
	if dragCard:
		dragCard.remove_child(dropper)
		add_child(dropper)
		dropper.visible = false
		if dropZone:
			if typeof(dropZone) == TYPE_INT:
				match dropZone:
					1:
						if currentPlayer == mainPlayerNumber and mainPlayer().plays > 0:
#							hand().remove_at(dragCard.slot)
							layoutPlayerCards()
							playCard(mainPlayerNumber,dragCard)
							dragCard = null
						else:
							returnDragCard()
					2:
						removeHighlight(dragCard)
						moveCard(dragCard,players[mainPlayerNumber].hand.back())
						dragCard.grabable = true
						dragCard = null
			else:
				removeHighlight(dragCard)
				moveCard(dragCard,dropZone)
				dragCard.grabable = true
				dragCard = null
				
		else:
			returnDragCard()

func returnDragCard():
	removeHighlight(dragCard)
	var mover = dragCard
	var t = await ref.tween(dragCard,"position",dragCard.prevPos,.5)
	dragCard = null
	t.tween_callback(func():
		mover.grabable = true)

func getDraws(playerNumber):
	var bonus = 0
	if ruleFlags["Poor Bonus"]:
		bonus = 1 if playerNumber == whoHasPoorBonus() else 0
	return ruleFlags["Draw"]+inflation()+bonus

func getPlays(playerNumber):
	var bonus = 0
	if ruleFlags["Rich Bonus"]:
		bonus = 1 if playerNumber == whoHasRichBonus() else 0
	return ruleFlags["Play"]+inflation()+bonus

func whoHasRichBonus():
	var max = 0
	var whoHasMax = []
	for p in players:
		if p.keepers.size() > max:
			max = p.keepers.size()
			whoHasMax = [p.number]
		elif max>0 and p.keepers.size() == max:
			whoHasMax.append(p.number)
	
	if whoHasMax.size() == 1:
		return whoHasMax[0]
	else:
		return null
		
func whoHasPoorBonus():
	var min = 99
	var whoHasMin = []
	for p in players:
		if p.keepers.size() < min:
			min = p.keepers.size()
			whoHasMin = [p.number]
		elif p.keepers.size() == min:
			whoHasMin.append(p.number)
		
	if whoHasMin.size() == 1:
		return whoHasMin[0]
	else:
		return null
			
		
	
func clickOnPlayerDock():
	if $anim.is_playing():
		return
	if not playerView:
		$anim.play("panUp")
		playerView = true
	else:
		$anim.play_backwards("panUp")
		playerView = false
	

				
func moveCard(c1,c2):
#	print("Move: ",c1.def," after ",c2.def)
	var hand = hand()
	if c1.slot<c2.slot:
		hand.insert(c2.slot+1,c1)
		hand.remove_at(c1.slot)
	else:
		hand.remove_at(c1.slot)
		hand.insert(c2.slot,c1)
	layoutPlayerCards()

func moveTo(node,toPos,time):
	return await ref.tween(node,"position",toPos,time)
	
func hand():
	return players[mainPlayerNumber].hand

func mainPlayer():
	return players[mainPlayerNumber]

func rulesHas(id):
	for type in ref.RULE_TYPE:
		for obj in rules[type]:
			if typeof(obj) == TYPE_ARRAY:
				for card in obj:
					if card.id == id:
						return true
			else:
				var card = obj
				if card.id == id:
					return true
	#card not found					
	return false
		
func inflation():
	return 1 if ruleFlags["Inflation"] else 0		
		
		
func _on_drop_zone_mouse_entered(arg):
	match arg:
		2:
			mouseOverHand = true
	
		

func _on_drop_zone_mouse_exited(arg):
		match arg:
			2:
				mouseOverHand = false
		
	
func _on_drop_zone_area_entered(area, arg):
	dropZone = arg


func _on_drop_zone_area_exited(area, arg):
	if typeof(dropZone) == TYPE_INT:
		if dropZone == arg:
			dropZone = null
