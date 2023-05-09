extends Control


func construct(complete_time, moves_made):
	$CompleteTime.text = "%d:%02d" % [floor(complete_time / 60), int(complete_time) % 60]
	$Moves.text = str(moves_made)


func _on_new_game_pressed():
	get_tree().get_root().get_node("Main/Table").new_game()


func _on_replay_pressed():
	get_tree().get_root().get_node("Main/Table").replay()
