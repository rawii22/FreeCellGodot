extends Control

var table
var GUI
var hand = [] #This is to allow independence from any parent screen that uses this screen.
var regex

func _ready():
	enable_simulate_button(false)
	table = get_tree().get_root().get_node("Main/Table")
	GUI = get_tree().get_root().get_node("Main/GUI")
	regex = RegEx.new()
	regex.compile("^[2-9ATJQK][SCDH]->((FREECELL|FOUNDATION)[1-4]|(COLUMN)[1-8])$")


func _on_exit_button_pressed():
	hide()


func _on_simulate_moves_pressed():
	GUI.hide_all_ui()
	table.simulate(hand.duplicate(), $HistoryText.text.split("\n"))


func set_hand(new_hand):
	hand = new_hand


func enable_simulate_button(value):
	if value:
		$SimulateMoves/Label.add_theme_color_override("font_color", Color("009b00"))
		$SimulateMoves.disabled = false
	else:
		$SimulateMoves/Label.add_theme_color_override("font_color", Color("d83500"))
		$SimulateMoves.disabled = true


func _on_history_text_text_changed():
	enable_simulate_button(false)
	for move in $HistoryText.text.split("\n"):
		if !regex.search(move.to_upper()):
			return
	
	enable_simulate_button(true)
