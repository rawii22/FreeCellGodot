extends Control

var table

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	table = get_tree().get_root().get_node("Main/Table")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_exit_button_pressed():
	hide()


func _input(event):
	if event.is_action_pressed("Info"):
		visible = !visible


func _on_reset_stats_visibility_changed():
	if get_parent() != null:
		if visible:
			get_parent().ui_changed(1)
			get_parent().get_node("SettingsMenu").lose_focus()
		else:
			get_parent().ui_changed(-1)
			if get_parent().get_node("SettingsMenu").visible:
				get_parent().get_node("SettingsMenu/Resume").grab_focus()
