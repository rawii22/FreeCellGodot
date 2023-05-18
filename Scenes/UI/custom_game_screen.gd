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
	#Loading these textures here, rather than lazy loading them on the spot, makes the screen much faster.
	for i in range(52):
		textures.push_back(load("res://Assets/CardIcons/" + number_to_icon_name(i)))


func _on_exit_button_pressed():
	hide()


func _on_visibility_changed():
	if GUI != null:
		$CardList.text = ""
		if visible:
			enable_play_button(false)
			hand.clear()
			hand = table.current_hand.duplicate()
			$CardList.text = hand_to_string(hand)
			update_screen()
			GUI.block_ui(true)
			select_area($Table/CustomCardArea1)
			$CardList.grab_focus()
			$MoveHistory.hide()
		else:
			GUI.block_ui(false)


func _on_play_hand_pressed():
	GUI.hide_all_ui()
	table.new_game(false, -1, hand.duplicate())


func _on_card_list_text_changed(new_text):
	var old_column_position = $CardList.get_caret_column()
	if new_text.contains(" "): #Clean the text if contains spaces.
		var space_count = new_text.count(" ")
		new_text = new_text.replace(" ", "")
		$CardList.text = new_text
		old_column_position -= space_count
	$CardList.set_caret_column(old_column_position)
	update_screen(new_text)


func _on_move_history_escape_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
		$MoveHistory.hide()


func _on_add_move_set_pressed():
	$MoveHistory.show()


func _on_move_history_visibility_changed():
	if $MoveHistory.visible:
		$MoveHistoryEscape.show()
		$MoveHistory/HistoryText.editable = true
	else:
		$MoveHistoryEscape.hide()
		$MoveHistory/HistoryText.editable = false


func select_area(area):
	if selected_area != null:
		selected_area.unselect()
	area.select()
	selected_area = area


func clear_card_area(area_id):
	if area_id <= hand.size():
		remove_card(hand[area_id - 1])


#This function will add the card to the hand in the proper place.
# It will also tell the selector whether the card was already in the hand so it can know to
# unpress itself or not.
func add_card(card_id):
	var card_already_present = hand.has(card_id)
	var new_hand = []
	if selected_area.area_id > hand.size():
		for value in hand:
			new_hand.push_back(value)
		for i in range(hand.size(), selected_area.area_id - 1):
			new_hand.push_back(null)
		new_hand.push_back(card_id)
		hand.clear()
		hand = new_hand
	else:
		hand[selected_area.area_id - 1] = card_id
	update_screen()
	return card_already_present


#Removes from the hand and updates the screen.
func remove_card(card_id):
	if hand.has(card_id):
		var removed_card_position = hand.find(card_id)
		hand[hand.find(card_id)] = null
		update_screen()
		return removed_card_position
	return null


func enable_play_button(value):
	if value:
		$PlayHand/Label.add_theme_color_override("font_color", Color("009b00"))
		$PlayHand.disabled = false
		$AddMoveSet.show()
		$MoveHistory.set_hand(hand)
	else:
		$PlayHand/Label.add_theme_color_override("font_color", Color("d83500"))
		$PlayHand.disabled = true
		$AddMoveSet.hide()
		$MoveHistory/HistoryText.text = ""
		$MoveHistory.enable_simulate_button(false)


#This is where all the action is happening visually. If a string is not specified, this means that
# an internal function has made a change and it will display the data stored in "hand" (assuming it has
# already been updated). If a string is specified, this means the user is typing into the CardList
# text box. If the hand array or CardList text box is ever changed, this function must be called
# immediately after for changes to be reflected.
func update_screen(string_data = null):
	var manual_entry = false
	if string_data == null:
		string_data = hand_to_string(hand)
	else:
		manual_entry = true
	
	enable_play_button(validate(string_data))
	if can_display_hand:
		#Reset the screen
		for value in card_values:
			get_node("CardSelector/CustomCardSelector" + str(value + 1)).enable()
			get_node("CardSelector/CustomCardSelector" + str(value + 1)).unpress()
			get_node("Table/CustomCardArea" + str(value + 1)).set_texture(preload("res://Assets/CardIcons/cardIconEmpty.png"))
		for i in range(hand.size()):
			if hand[i] != null:
				get_node("Table/CustomCardArea" + str(i + 1)).set_texture(textures[hand[i]])
				get_node("CardSelector/CustomCardSelector" + str(hand[i] + 1)).press()
		
		if manual_entry:
			var old_column_position = $CardList.get_caret_column()
			$CardList.text = string_data
			$CardList.set_caret_column(old_column_position)
		else:
			#Remove trailing commas if entry is automatic. Otherwise, the user would not be able to type commas at the end of the string
			#The host array still contains trailing null entries, but that isn't a problem.
			$CardList.text = string_data.rstrip(",")
	else:
		#Disable the screen since the string in CardList is invalid.
		for value in card_values:
			get_node("Table/CustomCardArea" + str(value + 1)).set_texture(preload("res://Assets/CardIcons/cardIconEmpty.png"))
			get_node("CardSelector/CustomCardSelector" + str(value + 1)).disable()


func hand_to_string(array):
	var hand_string = ""
	for i in range(array.size()):
		if array[i] != null:
			hand_string += str(array[i])
		if i != array.size() - 1: #Don't print out a comma if it is the last number
			hand_string += ","
	return hand_string


#I don't want to imagine the big O complexity of this function...
# Array validation pain. If a string passes enough checks to be displayable, the hand array will
# automatically be updated. If the string is invalid, host will remain cleared and it will not be
# accessible.
func validate(text):
	hand.clear()
	can_display_hand = false
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
	
	#If the hand is incomplete, check for duplicates. If it passes, the hand can be displayed.
	if results_int.size() < 52 or results_int.find(null) != -1:
		for i in range(results_int.size()):
			if results_int[i] != null and results_int.find(results_int[i], i + 1) != -1:
				return false
		can_display_hand = true
		hand = results_int
		return false
	
	#If the hand is theoretically complete, check if it really contains all the values.
	for element in card_values:
		if !results_int.has(element):
			return false
	
	can_display_hand = true
	hand = results_int
	return true


#This is for converting card IDs to their texture name.
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
