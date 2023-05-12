extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	get_tree().set_auto_accept_quit(false)
	get_tree().get_root().get_node("Main/Table").new_game()


func _input(event):
	if get_tree().get_root().get_node("Main/GUI").open_ui == 0 and !get_tree().get_root().get_node("Main/GUI").block_ui_changes:
		if event.is_action_pressed("New Game"):
			get_tree().get_root().get_node("Main/Table").new_game()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST and !get_tree().get_root().get_node("Main/GUI/SettingsMenu").quitting:
		get_tree().get_root().get_node("Main/GUI/SettingsMenu")._on_quit_pressed()

