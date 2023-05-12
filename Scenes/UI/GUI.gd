extends Node2D

var table
var open_ui = 0
var block_ui_changes = false

# Called when the node enters the scene tree for the first time.
func _ready():
	table = get_tree().get_root().get_node("Main/Table")


func _on_custom_game_button_pressed():
	$CustomGameScreen.show()


#This is to prevent race conditions. Do not set the time_paused variable from any other script.
#If two UI screens try to alter it at the same time when one is closing and the other is opening,
#there's no telling what value time_paused will be holding.
func ui_changed(value):
	open_ui += value
	table.set_time_paused(open_ui != 0)
	if open_ui > 0:
		$DarkOverlay.show()
	else:
		$DarkOverlay.hide()


func hide_all_ui():
	$SettingsMenu.hide()
	$InfoScreen.hide()
	$CustomGameScreen.hide()


func block_ui(value):
	block_ui_changes = value
	if open_ui > 0:
		table.set_time_paused(true)
	else:
		table.set_time_paused(value)
