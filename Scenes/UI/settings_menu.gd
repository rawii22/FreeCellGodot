extends Control

@export var confirm_screen_scene: PackedScene

var table
var GUI
var lineedit_focused
var old_text

var quitting = false

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


func _input(event):
	if !lineedit_focused and event.is_action_pressed("Toggle Fullscreen"):
		_on_fullscreen_pressed()


func _on_visibility_changed():
	if get_parent() != null:
		if visible:
			$NewGame/LineEdit.text = ""
			old_text = ""
			get_parent().ui_changed(1)
			$Resume.grab_focus()
		else:
			get_parent().ui_changed(-1)


func _on_resume_pressed():
	hide()


func _on_replay_pressed():
	hide()
	table.replay()


func _on_new_game_pressed():
	hide()
	if $NewGame/LineEdit.text != "":
		table.new_game(false, int($NewGame/LineEdit.text))
	else:
		table.new_game()


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
	hide()
	_on_new_game_pressed()


func _on_random_deal_pressed():
	if !table.is_random:
		randomize()
	$NewGame/LineEdit.text = str(randi() % 10000000)
	$NewGame/LineEdit.grab_focus()
	$NewGame/LineEdit.set_caret_column($NewGame/LineEdit.text.length())


func _on_fullscreen_pressed():
	if get_parent().block_ui_changes:
		return
	
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
	quitting = true
	var response = true
	if !table.won and table.move_made_on_current_hand:
		var confirmation_screen = confirm_screen_scene.instantiate()
		get_parent().add_child(confirmation_screen)
		response = await confirmation_screen.confirm("Quit?\n(Unfinished non-custom games will count as a loss)", true)
		confirmation_screen.queue_free()
	if response:
		table.end_game(true)
		get_tree().quit()
	quitting = false


func lose_focus():
	$Resume.grab_focus()
	$Resume.release_focus()


func toggle():
	if get_parent().block_ui_changes:
		return
	#If there are other things on screen, close them out first and show settings on top.
	if (get_parent().open_ui > 1 and visible) or (get_parent().open_ui > 0 and !visible):
		get_parent().hide_all_ui()
		show()
	else:
		visible = !visible
