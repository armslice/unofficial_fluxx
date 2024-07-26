extends Node2D

class_name Card

@export var def: CardDefinition

var prevPos = null
var mouseOffset = null
var highlightable = false
var grabable = false
var highlighted = false
var slot = null
var prevZ = 0
var isDropzone = true
var distanceToMouse = null
var justMoved = false
var played

var canPress = true
var longPress = 0
var longPressAction: Callable

func _process(delta):
	
	if canPress and longPressAction and $button.is_pressed():
		longPress += delta
		$button/TextureProgressBar.value = longPress*100
		
		if longPress > 1:
			executeLongPress()
	else:
		longPress = 0
		$button/TextureProgressBar.value = 0
		
#	if ref.game.dev:
#		if grabable:
#			if ref.board.dragCard and self == ref.board.dragCard:
#				$button.modulate = Color.GREEN
#			else:
#				$button.modulate = Color.YELLOW
#		else:
#			$button.modulate = Color.RED
	
func setCard():
	#setColor/Type text
	def.setup()
	match def.type:
		ref.TYPE.GOAL:
			set_color(Color("f60096"))
			$facebg/face/Text/Type.text = "GOAL"
		ref.TYPE.RULE:
			set_color(Color("e8c400"))
			$facebg/face/Text/Type.text = "NEW RULE"
		ref.TYPE.ACTION:
			set_color(Color("00a0f7"))
			$facebg/face/Text/Type.text = "ACTION"
			$facebg/face/Text/vbox/center.visible = false
		ref.TYPE.KEEPER:
			set_color(Color("9ec809"))
			$facebg/face/Text/Type.text = "KEEPER"
	
	$facebg/face/Text/SideName.text = def.id.to_upper()
	if def.type == ref.TYPE.GOAL:
		#set goal gfx
		$facebg/face/Text/vbox/center.queue_free()
	else:
		$facebg/face/Text/GoalGfx.queue_free()
	if def.type == ref.TYPE.KEEPER:
		$facebg/face/Text/vbox.queue_free()
		$facebg/face/Text/keeper/Title.text = def.id
	else:
		$facebg/face/Text/keeper.queue_free()
			
		var titleSplit = def.title.split("*")
		for str in titleSplit:
			$facebg/face/Text/vbox/Title.text += str + "\n"
		$facebg/face/Text/vbox/Title.text = $facebg/face/Text/vbox/Title.text.strip_edges()
		$facebg/face/Text/vbox/Body.text = def.description
		if def.subtitle == "":
			$facebg/face/Text/vbox/Subtitle.visible = false
		else:
			$facebg/face/Text/vbox/Subtitle.text = def.subtitle
	
func set_color(color:Color):
	$facebg/face.self_modulate = color


func deal(show = false):
	if show:
		$anim.play("dealToSelf")
		await  $anim.animation_finished
		highlightable = true
		$back.queue_free()
	else:
		$anim.play("dealToOther")

func reveal():
	$anim.play("dealToSelf")

func highlight(activate,immediate=false):
	if not highlightable:
		return
	if activate and not highlighted:
		highlighted = true
		prevZ = z_index
		z_index = 150
		$anim.play("grow")
		return
	elif highlighted:
		highlighted = false
		z_index = prevZ
		if immediate:
			$anim.play("played_reset")
		else:
			$anim.play_backwards("grow")

func play():
	played = true
	highlight(false)
	grabable = false
	isDropzone = false


func minimize():
	scaleTo(.5)

func scaleTo(size):
	if $anim.is_playing():
		await $anim.animation_finished
	ref.tween(self,"scale",Vector2(size,size),.5)
	

#func active(active):
##	$area.visible = active
##	$button.visible = active
##	$area/collision.disabled = not active


func _on_area_mouse_entered():
	ref.board.mouseEnterCard(self)


func _on_area_mouse_exited():
	ref.board.mouseExitCard(self)


func on_mouse_down():
	if grabable:
		prevPos = position
		mouseOffset = get_global_mouse_position()-position
		ref.board.grabCard(self)

func _to_string():
	return "%s"%def.title

	
func executeLongPress():
	canPress = false
	if longPressAction:
		longPressAction.call()
		$button/TextureProgressBar.value = 0
	ref.board.showMessage("%s pressed"%def.id,1)
	
