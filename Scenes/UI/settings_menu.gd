extends Control

var table
var GUI
var lineedit_focused
var old_text

var FSenabled = "Fullscreen:\nEnabled"
var FSdisabled = "Fullscreen:\nDisabled"

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	table = get_tree().get_root().get_node("Main/Table")
	GUI = get_tree().get_root().get_node("Main/GUI")
	if is_fullscreen():
		$Fullscreen.get_node("Label").text = FSenabled
	else:
		$Fullscreen.get_node("Label").text = FSdisabled


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if !lineedit_focused and event.is_action_pressed("Toggle Fullscreen"):
		_on_fullscreen_pressed()


func _on_visibility_changed():
	$NewGame/LineEdit.text = ""
	old_text = ""
	if get_parent() != null:
		if visible:
			get_parent().ui_changed(1)
			$Resume.grab_focus()
		else:
			get_parent().ui_changed(-1)


func _on_resume_pressed():
	hide()


func _on_replay_pressed():
	table.replay()
	hide()


func _on_new_game_pressed():
	if $NewGame/LineEdit.text != "":
		table.new_game(false, int($NewGame/LineEdit.text))
	else:
		table.new_game()
	hide()


func _on_line_edit_focus_entered():
	lineedit_focused = true


func _on_line_edit_focus_exited():
	lineedit_focused = false


func _on_line_edit_text_changed(new_text):
	if new_text != "" and !new_text.is_valid_int():
		$NewGame/LineEdit.text = old_text
		$NewGame/LineEdit.set_caret_column($NewGame/LineEdit.text.length())
		return
	old_text = new_text


func _on_line_edit_text_submitted(new_text):
	_on_new_game_pressed()
	hide()


func _on_random_deal_pressed():
	if !table.is_random:
		randomize()
	$NewGame/LineEdit.text = str(randi() % 10000000)
	$NewGame/LineEdit.grab_focus()
	$NewGame/LineEdit.set_caret_column($NewGame/LineEdit.text.length())
	


func _on_fullscreen_pressed():
	if toggle_fullscreen():
		$Fullscreen.get_node("Label").text = FSenabled
	else:
		$Fullscreen.get_node("Label").text = FSdisabled


#returns true if fullscreen was just activated, false otherwise
func toggle_fullscreen():
	if is_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		return false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return true


func is_fullscreen():
	return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


func _on_info_pressed():
	GUI.get_node("InfoScreen").show()


func _on_quit_pressed():
	get_tree().quit()


func lose_focus():
	$Resume.grab_focus()
	$Resume.release_focus()
