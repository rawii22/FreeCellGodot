extends Node2D

var open_ui = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#This is to prevent race conditions. Do not set the time_paused variable from any other script.
#If two UI screens try to alter it at the same time when one is closing and the other is opening,
#there's no telling what value time_paused will be holding.
func ui_changed(value):
	open_ui += value
	get_tree().get_root().get_node("Main/Table").set_time_paused(open_ui != 0)
	if open_ui > 0:
		$DarkOverlay.show()
	else:
		$DarkOverlay.hide()


func hide_all_ui():
	$SettingsMenu.hide()
	$InfoScreen.hide()
