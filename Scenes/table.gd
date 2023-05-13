extends Node2D

@export var card_scene: PackedScene
@export var confirm_screen_scene: PackedScene
@export var win_screen_scene: PackedScene

const save_file_location = "res://savegame.save"

var special_hand = [51,38,25,12,50,37,24,11,49,36,23,10,48,35,22,9,47,34,21,8,46,33,20,7,45,32,19,6,44,31,18,5,43,30,17,4,42,29,16,3,41,28,15,2,40,27,14,1,39,26,13,0]

var movement_occuring = false
var card_spacing = 92

var max_stack_size
var move_count = 0
var time_elapsed = 0
var time_paused = true

var auto_completing = false
var auto_complete_rejected = false
var won = false
var win_screen

var current_hand = []
var is_random = true
var is_custom = false
var move_made_on_current_hand = false

#These initializations are here to make sure the game has something to alter while creating a new game
var free_columns = 0
var free_cells = 4

class Move:
	var card
	var first_position
	var second_position
	var increment_moves

var games_played
var games_won
var best_time
var best_moves

const time_reset_value = 99999999 #~3 years
const move_reset_value = 9223372036854775807 #max value of signed 64 bit int

var move_history = []
var redo_stack = []


# Called when the node enters the scene tree for the first time.
func _ready():
	#TODO: Read the save file. Set to defaults if none.
	if !FileAccess.file_exists(save_file_location):
		reset_stats()
		return
	
	var save_file = FileAccess.open(save_file_location, FileAccess.READ)
	var json_string = save_file.get_line()
	var json = JSON.new()
	var json_result = json.parse(json_string)
	if json_result != OK:
		reset_stats()
		return
	var save_data = json.get_data()
	games_played = save_data["games_played"]
	games_won = save_data["games_won"]
	best_time = save_data["best_time"]
	best_moves = save_data["best_moves"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !time_paused and move_count > 0:
		time_elapsed += delta
		$TimerText.text = "Time: " + "%d:%02d" % [floor(time_elapsed / 60), int(time_elapsed) % 60]


#Block table input if there is any ui open or if there is a blocking ui call (likely a confirmation screen).
func _input(event):
	if get_tree().get_root().get_node("Main/GUI").open_ui == 0 and !get_tree().get_root().get_node("Main/GUI").block_ui_changes and !auto_completing:
		if event.is_action_pressed("Undo"):
			undo()
		elif event.is_action_pressed("Redo"):
			redo()
		elif event.is_action_pressed("Replay"):
			replay()


func _on_undo_button_pressed():
	undo()


func _on_redo_button_pressed():
	redo()


func _on_replay_button_pressed():
	replay()


func _on_autocomplete_button_pressed():
	auto_complete_rejected = false
	check_autocomplete()


#This is to prevent multiple inputs from being entered at once, likely resulting in crashes.
func toggle_action_happening():
	movement_occuring = !movement_occuring


func is_action_happening():
	return movement_occuring


func set_time_paused(value):
	if won or move_count < 1:
		time_paused = true
	else:
		time_paused = value


func new_game(replay_hand = false, seed_num = -1, custom_deal = null):
	if !won and move_made_on_current_hand and !replay_hand:
		var confirmation_screen = confirm_screen_scene.instantiate()
		add_child(confirmation_screen)
		var prompt
		if is_custom:
			prompt = "Start a new game?\n(Custom deals do not affect statistics)"
		else:
			prompt = "Start a new game?\n(This will count as a loss)"
		var response = await confirmation_screen.confirm(prompt, true)
		confirmation_screen.queue_free()
		if response:
			end_game()
		else:
			return
	
	if !replay_hand:
		if custom_deal != null:
			current_hand = custom_deal
			is_custom = true
		else:
			is_custom = false
	
	clear_board()
	deal_cards(replay_hand, seed_num)


func clear_board():
	for i in range(8):
		get_node("Column" + str(i + 1)).cards.clear()
		
	for i in range(4):
		get_node("FreeCell" + str(i + 1)).has_card = false
		get_node("Foundation" + str(i + 1)).cards.clear()
		get_node("Foundation" + str(i + 1)).is_full = false

	get_tree().call_group("card", "queue_free")
	
	if won:
		remove_child(win_screen)
		win_screen.queue_free()
	
	move_history.clear()
	redo_stack.clear()
	won = false
	auto_complete_rejected = false
	$AutocompleteButton.hide()
	move_count = 0
	time_elapsed = 0
	set_time_paused(true)
	movement_occuring = false
	$TimerText.text = "Time: " + "%d:%02d" % [floor(time_elapsed / 60), int(time_elapsed) % 60]
	$MoveCounter.text = "Moves: " + str(move_count)


func deal_cards(replay_hand, seed_num):
	var cards = []
	
	if !replay_hand:
		if !is_custom:
			current_hand.clear()
			for i in range(52):
				current_hand.append(i)
			if seed_num > -1:
				current_hand = microsoft_freecell_rng(seed_num)
				is_random = false
				$DealNumber.text = "Deal: #" + str(seed_num)
			else:
				$DealNumber.text = ""
				is_random = true
				current_hand.shuffle()
			if seed_num == 2023:
				current_hand.clear()
				current_hand = special_hand.duplicate() # Duplicate here or else the original array will be cleared as well when a new game is started. This is because of pointers.
				is_custom = true
		else:
			$DealNumber.text = "Custom Deal"
		move_made_on_current_hand = false #This must be here and not in clear_board since only deal_cards can tell if the user is replaying
	
	for i in current_hand:
		var card = card_scene.instantiate()
		
		match i / 13:
			0:
				card.suit = "spade"
				card.color = "black"
			1:
				card.suit = "club"
				card.color = "black"
			2:
				card.suit = "diamond"
				card.color = "red"
			3:
				card.suit = "heart"
				card.color = "red"
		
		card.value = (i % 13) + 1
		card.card_name = str(card.value) + "_" + card.suit
		
		card.get_node("Sprite2D").texture = load("res://Assets/Cards/" + card.card_name + ".png")
		
		cards.append(card)
	
	var card_to_deal
	
	#TODO: Dealing animation?
	
	for i in range(6):
		for j in range(8):
			card_to_deal = cards.pop_front()
			get_node("Column" + str(j + 1)).add_card(card_to_deal, false)
			card_to_deal.show()
	
	for i in range(4):
		card_to_deal = cards.pop_front()
		get_node("Column" + str(i + 1)).add_card(card_to_deal, false)
		card_to_deal.show()
	
	free_columns = 0
	free_cells = 4
	calculate_max_stack_size()


func move_made(move, record_move = true):
	if record_move:
		move_history.push_back(move)
		redo_stack.clear()
		
	if move.increment_moves:
		move_count += 1
		set_time_paused(false)
		$MoveCounter.text = "Moves: " + str(move_count)
		move_made_on_current_hand = true
	
	check_autocomplete()
	
	var full_foundations = 0
	for i in range(4):
		if get_node("Foundation" + str(i + 1)).is_full:
			full_foundations += 1
	if full_foundations == 4:
		won = true
		end_game()
		return


#If the cards can be auto completed, this function will prompt the user if they want to auto complete
# the game. If they reject it, it will not prompt them again until they hit the autocomplete button.
# When autocomplete starts, it will simply defer to the the auto_move function cards_remaining number
# of times.
func check_autocomplete():
	if !auto_completing: #This is to avoid one massive infinite loop
		var cards_remaining = 0
		for i in range(8):
			var previous_card_value = 13
			for card in get_node("Column" + str(i + 1)).cards:
				cards_remaining += 1
				if card.value <= previous_card_value:
					previous_card_value = card.value
				else:
					return
		
		for i in range(4):
			if get_node("FreeCell" + str(i + 1)).has_card:
				cards_remaining += 1
		
		$AutocompleteButton.show()
		if !auto_complete_rejected:
			var confirmation_screen = confirm_screen_scene.instantiate()
			add_child(confirmation_screen)
			var response = await confirmation_screen.confirm("Autocomplete?", true)
			confirmation_screen.queue_free()
			if response:
				auto_completing = true
				get_tree().get_root().get_node("Main/GUI").block_ui_changes = true
				for i in range(cards_remaining):
					await get_tree().create_timer(0.06).timeout
					auto_move()
				auto_completing = false
				get_tree().get_root().get_node("Main/GUI").block_ui_changes = false
			else:
				auto_complete_rejected = true


#This is supposed to be like an auto-move for cards that can go to the foundation. It only moves one card at a time.
#If you want to move more than one card at a time to the foundation, try removing the checks for move_occured as a start.
func auto_move():
	if !movement_occuring:
		var current_area
		var current_card
		var move_occured = false
		
		for i in range(8):
			if !move_occured:
				current_area = get_tree().get_root().get_node("Main/Table/Column" + str(i + 1))
				if current_area.cards.size() > 0:
					current_card = current_area.cards.back()
					if can_go_in_foundation(current_card):
						move_occured = current_card.on_click(true)
		
		for i in range(4):
			if !move_occured:
				current_area = get_tree().get_root().get_node("Main/Table/FreeCell" + str(i + 1))
				if current_area.has_card:
					current_card = current_area.held_card
					if can_go_in_foundation(current_card):
						move_occured = current_card.on_click(true)


func can_go_in_foundation(card):
	var current_foundation
	for j in range(4):
		current_foundation = get_tree().get_root().get_node("Main/Table/Foundation" + str(j + 1))
		if current_foundation.can_place_card(card):
			return true


func update_free_cells(delta, is_column = false):
	if is_column:
		free_columns += delta
	else:
		free_cells += delta
	calculate_max_stack_size()


func calculate_max_stack_size():
	max_stack_size = (pow(2, free_columns)) * (free_cells + 1)


func undo():
	if !movement_occuring and !won and move_history.size() > 0:
		var previous_move = move_history.pop_back()
		redo_stack.push_front(previous_move)
		previous_move.card.make_move(previous_move.first_position, false)
		move_made(previous_move, false)


func redo():
	if !movement_occuring and redo_stack.size() > 0:
		var next_move = redo_stack.pop_front()
		move_history.push_back(next_move)
		next_move.card.make_move(next_move.second_position, false)
		move_made(next_move, false)


func replay():
	if !movement_occuring and !get_tree().get_root().get_node("Main/GUI").block_ui_changes and !auto_completing:
		new_game(true)


func end_game(quitting = false):
	set_time_paused(true)
	#If the game is being closed imediately after the player won, don't count the win twice.
	if won and !quitting:
		win_screen = win_screen_scene.instantiate()
		win_screen.construct(time_elapsed, move_count, is_custom)
		add_child(win_screen)
		win_screen.show()
		if !is_custom:
			games_played += 1
			games_won += 1
			if time_elapsed < best_time:
				best_time = time_elapsed
			if move_count < best_moves:
				best_moves = move_count
	elif !won and move_made_on_current_hand and !is_custom:
		games_played += 1
	save()


func save():
	var save_file = FileAccess.open(save_file_location, FileAccess.WRITE)
	var save_data = {
		"games_played" : games_played,
		"games_won" : games_won,
		"best_time" : best_time,
		"best_moves" : best_moves
	}
	var save_data_json = JSON.stringify(save_data)
	save_file.store_line(save_data_json)


func reset_stats():
	games_played = 0
	games_won = 0
	best_time = time_reset_value
	best_moves = move_reset_value
	save()


func microsoft_freecell_rng(seed):
	var deck = [13,26,39,0,14,27,40,1,15,28,41,2,16,29,42,3,17,30,43,4,18,31,44,5,19,32,45,6,20,33,46,7,21,34,47,8,22,35,48,9,23,36,49,10,24,37,50,11,25,38,51,12]
	var max_32_int = 2147483647
	for i in range(51, 0, -1):
		seed = ((214013 * seed) + 2531011) & max_32_int
		var r = (seed >> 16) % (i + 1)
		var temp = deck[r]
		deck[r] = deck[i]
		deck[i] = temp
	deck.reverse()
	return deck
