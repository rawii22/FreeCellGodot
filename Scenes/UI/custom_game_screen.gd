extends Control


var GUI
var table

var selected_area = null
var card_values = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51]
var textures = []
var hand = []
var can_display_hand = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	GUI = get_tree().get_root().get_node("Main/GUI")
	table = get_tree().get_root().get_node("Main/Table")
	for i in range(52):
		textures.push_back(load("res://Assets/CardIcons/" + number_to_icon_name(i)))


func _on_exit_button_pressed():
	hide()


func _on_visibility_changed():
	if GUI != null:
		$CardList.text = ""
		if visible:
			validate("")
			GUI.block_ui(true)
			enable_play_button(false)
			select_area($Table/CustomCardArea1)
			$CardList.grab_focus()
		else:
			GUI.block_ui(false)


func _on_play_hand_pressed():
	GUI.hide_all_ui()
	table.new_game(false, -1, hand)


func _on_card_list_text_changed(new_text):
	var old_column_position = $CardList.get_caret_column()
	if new_text.contains(" "):
		new_text = new_text.replace(" ", "")
		$CardList.text = new_text
		old_column_position -= 1
	$CardList.set_caret_column(old_column_position)
	enable_play_button(validate(new_text))
	update_cards()


func select_area(area):
	if selected_area != null:
		selected_area.unselect()
	area.select()
	selected_area = area


func enable_play_button(value):
	if value:
		$PlayHand/Label.add_theme_color_override("font_color", Color("009b00"))
		$PlayHand.disabled = false
	else:
		$PlayHand/Label.add_theme_color_override("font_color", Color("d83500"))
		$PlayHand.disabled = true


func update_cards():
	if can_display_hand:
		for i in range(hand.size()):
			if hand[i] != null:
				get_node("Table/CustomCardArea" + str(i + 1)).set_texture(textures[hand[i]])
			else:
				get_node("Table/CustomCardArea" + str(i + 1)).set_texture(preload("res://Assets/CardIcons/cardIconEmpty.png"))
	else:
		for value in card_values:
			get_node("Table/CustomCardArea" + str(value + 1)).set_texture(preload("res://Assets/CardIcons/cardIconEmpty.png"))


#I don't want to imagine the big O complexity of this function...
func validate(text):
	hand.clear()
	can_display_hand = false
	update_cards()
	var results = text.split(",", true, 51)
	
	#Is each element a valid int (or null for empty slots)
	var results_int = []
	for element in results:
		if element == "":
			results_int.push_back(null)
		elif element.is_valid_int():
			results_int.push_back(int(element))
		else:
			return false
	
	#Are the ints within range (exception for null for empty slots)
	for element in results_int:
		if element != null and (element < 0 or element > 51):
			return false
	
	#When the hand is incomplete, check for duplicates. If it passes, the hand can be displayed.
	if results_int.size() < 52 or results_int.find(null) != -1:
		for i in range(results_int.size()):
			if results_int[i] != null and results_int.find(results_int[i], i + 1) != -1:
				return false
		can_display_hand = true
		hand = results_int
		return false
	
	#When the hand is complete, check if it really contains all the values.
	for element in card_values:
		if !results_int.has(element):
			return false
	
	can_display_hand = true
	hand = results_int
	
	return true


func number_to_icon_name(number):
	var icon_name = str((number % 13) + 1)
	match number / 13:
		0:
			icon_name += "_spade"
		1:
			icon_name += "_club"
		2:
			icon_name += "_diamond"
		3:
			icon_name += "_heart"

	return icon_name + "_icon.png"
