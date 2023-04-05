extends Node2D


var FSenabled = "Fullscreen:\nEnabled"
var FSdisabled = "Fullscreen:\nDisabled"

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_fullscreen():
		$Fullscreen.get_node("Label").text = FSenabled
	else:
		$Fullscreen.get_node("Label").text = FSdisabled


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_fullscreen_pressed():
	if toggle_fullscreen():
		$Fullscreen.get_node("Label").text = FSenabled
	else:
		$Fullscreen.get_node("Label").text = FSdisabled


func _input(event):
	if event.is_action_pressed("Toggle Fullscreen"):
		_on_fullscreen_pressed()


func is_fullscreen():
	return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


#returns true if fullscreen was just activated, false otherwise
func toggle_fullscreen():
	if is_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		return false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return true


func _on_quit_pressed():
	get_tree().quit()


func _on_resume_pressed():
	hide()


func _on_new_game_pressed():
	get_parent().get_parent().new_game()
	hide()
