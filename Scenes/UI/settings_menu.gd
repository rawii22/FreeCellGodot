extends Node2D

#===================================================
#TODO: Change the menu to work with a parent control node instead. This will make it infinitely easier
# to add new menu options. It will also stop you from having to manually change the click area of the
# DarkOverlay every time the menu size changes. With a control node you should be able to just block
# clicks from the mouse, and that's exactly what we want.
#===================================================

var table

var FSenabled = "Fullscreen:\nEnabled"
var FSdisabled = "Fullscreen:\nDisabled"

# Called when the node enters the scene tree for the first time.
func _ready():
	table = get_tree().get_root().get_node("Main/Table")
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


func _on_visibility_changed():
	if table != null and table.move_count > 0:
		table.time_paused = visible
