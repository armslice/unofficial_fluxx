extends Control

var player
var miniKeepers = []
const KEEPER_W = 70
const UI_W = 300


func setPlayer(p):
	player = p
	$name.text = p.name
	setKeepersForPlayer()

func addKeeper(id,layout=true):
	var keeper = ref.miniKeeper.instantiate()
	keeper.setKeeper(id)
	add_child(keeper)
	miniKeepers.append(keeper)
	if layout:
		layoutMiniKeepers()
	
	
func clearKeepers():
	for k in miniKeepers:
		queue_free()
		
func setKeepersForPlayer():
	if player.keepers.size() == 0:
		return
	clearKeepers()
	for k in player.keepers:
		addKeeper(k.def.id,false)
	layoutMiniKeepers()
	
func layoutMiniKeepers():
	var space = min(UI_W/miniKeepers.size(),KEEPER_W)
	for i in miniKeepers.size():
		miniKeepers[i].position = $miniKeeperSpot.position + Vector2(space*i,0)
		
func update():
	$info/cardCount.text = str(player.hand.size())
	$info/plays.text = str(player.plays)

		
		
		
		
	
