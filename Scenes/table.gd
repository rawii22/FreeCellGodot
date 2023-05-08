extends Node2D

@export var card_scene: PackedScene
@export var confirm_screen: PackedScene #TODO: Create this class and connect it
@export var win_screen: PackedScene #TODO: Create this class and connect it

var movement_occuring = false
var card_spacing = 92

var max_stack_size
var move_count = 0
var time_elapsed = 0
var time_paused = true
var auto_completing = false
var won = false

var current_hand = []
var previous_seed = -1
var is_random = true

#These initializations are here to make sure the game has something to alter while creating a new game
var free_columns = 0
var free_cells = 4

class Move:
	var card
	var first_position
	var second_position
	var increment_moves

class Stats:
	var games_played
	var games_won
	var best_time
	var best_moves

var current_stats
	
var move_history = []
var redo_stack = []


# Called when the node enters the scene tree for the first time.
func _ready():
	#TODO: Read the save file. Set to defaults if none.
	current_stats = Stats.new()
	current_stats.games_played = 0
	current_stats.games_won = 0
	current_stats.best_time = 0
	current_stats.best_moves = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !time_paused and move_count > 0:
		time_elapsed += delta
		$TimerText.text = "Time: " + "%d:%02d" % [floor(time_elapsed / 60), int(time_elapsed) % 60]


func _input(event):
	if !get_tree().get_root().get_node("Main/GUI/SettingsMenu").visible:
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


func _on_texture_button_pressed():
	replay()


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


func new_game(replay_hand = false, seed_num = -1):
	#TODO: if they have made at least one move, ask if they are sure they want to lose progress on the game? "Will be counted as a loss"
	if !won and move_count > 0:
		#Create scene instance,
		#If confirm newgame:
		lose()
	
	clear_board()
	deal_cards(replay_hand, seed_num)


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


func clear_board():
	for i in range(8):
		get_node("Column" + str(i + 1)).cards.clear()
		
	for i in range(4):
		get_node("FreeCell" + str(i + 1)).has_card = false
		get_node("Foundation" + str(i + 1)).cards.clear()
		get_node("Foundation" + str(i + 1)).is_full = false

	get_tree().call_group("card", "queue_free")
	
	if won:
		#TODO: Delete won screen
		pass
	
	move_history.clear()
	redo_stack.clear()
	move_count = 0
	time_paused = true
	time_elapsed = 0
	won = false
	$TimerText.text = "Time: " + "%d:%02d" % [floor(time_elapsed / 60), int(time_elapsed) % 60]
	$MoveCounter.text = "Moves: " + str(move_count)


func deal_cards(replay_hand, seed_num):
	var cards = []
	
	if !replay_hand:
		current_hand.clear()
		for i in range(52):
			current_hand.append(i)
		if seed_num > -1:
			seed(seed_num)
			is_random = false
			$DealNumber.text = "Deal: #" + str(seed_num)
		else:
			$DealNumber.text = ""
			if previous_seed != -1: # This to avoid calling randomize() more times than necessary
				randomize()
			is_random = true
		previous_seed = seed_num
		current_hand.shuffle()
	
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
	
	for i in range(8):
		for j in range(6):
			card_to_deal = cards.pop_front()
			get_node("Column" + str(i + 1)).add_card(card_to_deal, false)
			card_to_deal.show()
	
	for i in range(4):
		card_to_deal = cards.pop_front()
		get_node("Column" + str(i + 1)).add_card(card_to_deal, false)
		card_to_deal.show()
	
	free_columns = 0
	free_cells = 4
	calculate_max_stack_size()


func calculate_max_stack_size():
	max_stack_size = (2**free_columns) * (free_cells + 1)


func update_free_cells(delta, is_column = false):
	if is_column:
		free_columns += delta
	else:
		free_cells += delta
	calculate_max_stack_size()


func move_made(move, record_move = true):
	if record_move:
		move_history.push_back(move)
		redo_stack.clear()
		
	if move.increment_moves:
		move_count += 1
		set_time_paused(false)
		$MoveCounter.text = "Moves: " + str(move_count)
	
	check_autocomplete()
	
	var full_foundations = 0
	for i in range(4):
		if get_node("Foundation" + str(i + 1)).is_full:
			full_foundations += 1
	if full_foundations == 4:
		win()
		return


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
		
		#TODO: Confirm for auto complete
		auto_completing = true
		for i in range(cards_remaining):
			await get_tree().create_timer(0.15).timeout
			auto_move()
		auto_completing = false


func undo():
	if !won and move_history.size() > 0:
		var previous_move = move_history.pop_back()
		redo_stack.push_front(previous_move)
		previous_move.card.make_move(previous_move.first_position, false)
		move_made(previous_move, false)


func redo():
	if redo_stack.size() > 0:
		var next_move = redo_stack.pop_front()
		move_history.push_back(next_move)
		next_move.card.make_move(next_move.second_position, false)
		move_made(next_move, false)


func replay():
	new_game(true)


func win():
	time_paused = true
	won = true
	#TODO: Instantiate win screen
	
	current_stats.games_played += 1
	current_stats.games_won += 1
	if time_elapsed < current_stats.best_time:
		current_stats.best_time = time_elapsed
	if move_count < current_stats.best_moves:
		current_stats.best_moves = move_count
	
	#TODO: Save data to file
	save()


func lose():
	current_stats.games_played += 1
	
	#TODO: Save data to file
	save()


func save():
	#TODO: Export Stats class to file
	pass


func reset_stats():
	current_stats.games_played = 0
	current_stats.games_won = 0
	current_stats.best_time = 0
	current_stats.best_moves = 0
	save()
