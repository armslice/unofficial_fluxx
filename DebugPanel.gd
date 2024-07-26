extends Panel

var textBuffer = ""
var staticText = ""

func _ready():
	await get_tree().process_frame
	if ref.game.dev:
		set_process(true)
	
func _process(delta):
	$Label.text = textBuffer
	textBuffer = staticText+""
	
func debug(textArr):
	if ref.game.dev:
		if typeof(textArr)!= TYPE_ARRAY:
			textArr = [textArr]
		textBuffer+="\n"
		for t in textArr:
			textBuffer += "\n"+str(t)

func addLog(text):
	staticText += text


func _on_test_play_pressed():
	if not $PlayerControls/Player.text:
		$PlayerControls/Player.text = "0"
	ref.board.playCard(int($PlayerControls/Player.text),int($PlayerControls/Card.text))
	


func _on_test_draw_pressed():
	if not $PlayerControls/Player.text:
		$PlayerControls/Player.text = "0"
	ref.board.drawCard(int($PlayerControls/Player.text))


func _on_test_turn_pressed():
	if not $PlayerControls/Player.text:
		$PlayerControls/Player.text = "0"
	ref.board.takeTurn(int($PlayerControls/Player.text))
