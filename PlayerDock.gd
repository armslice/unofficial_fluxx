extends Node2D

var playerView = false

func playKeeper(playerSlot,id):
	get_node("p%s"%playerSlot).addKeeper(id)

func setCardCount(slotNumber,count):
	get_node("p%s/cardCount"%slotNumber).text = str(count)

func _on_texture_button_pressed():
	playerView = !playerView
	$TextureButton.size.y = 900 if playerView else 223
	ref.board.clickOnPlayerDock()
	pass # Replace with function body.

func setSlotPlayer(dockNumber,player):
	get_node("p%s"%dockNumber).setPlayer(player)

func update(dockNumber = null):
	if not dockNumber:
		for i in 3:
			get_node("p%s"%i).update()
	elif dockNumber == -1:
		pass #update the mainPlayer ui
	else:
		get_node("p%s"%dockNumber).update()
	

func keeperPosition(dockNumber):
	return get_node("p%s/keeperSpot"%dockNumber).global_position
