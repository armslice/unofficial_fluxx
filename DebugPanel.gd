extends Panel


var textBuffer = ""
var staticText = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = textBuffer
	textBuffer = staticText+""
	
func debug(textArr):
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
