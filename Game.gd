extends Node2D

var dev = true

func _ready():
	ref.game = self
	
func debug(text):
	$modal/DebugPanel.debug(text)
	
func log(text):
	$modal/DebugPanel.addLog(text)

func _input(event):
	if dev and event.is_action_pressed("toggleDebug"):
		$modal/DebugPanel.visible = !$modal/DebugPanel.visible


func _on_offline_pressed():
	$modal/Menu.visible = false
	$Board.visible = true
	$Board.testMatch()
