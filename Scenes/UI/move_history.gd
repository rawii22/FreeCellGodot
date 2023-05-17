extends Control

var table
var GUI
var hand = [] #This is to allow independence from any parent screen that uses this screen.

func _ready():
	enable_simulate_button(false)
	table = get_tree().get_root().get_node("Main/Table")
	GUI = get_tree().get_root().get_node("Main/GUI")


func _on_exit_button_pressed():
	hide()


func _on_simulate_moves_pressed():
	GUI.hide_all_ui()
	table.simulate(hand.duplicate(), $HistoryText.text.split("\n"))


func set_hand(new_hand):
	hand.clear()
	hand = new_hand


func enable_simulate_button(value):
	if value:
		$SimulateMoves/Label.add_theme_color_override("font_color", Color("009b00"))
		$SimulateMoves.disabled = false
	else:
		$SimulateMoves/Label.add_theme_color_override("font_color", Color("d83500"))
		$SimulateMoves.disabled = true
