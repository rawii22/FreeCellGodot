extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	get_tree().get_root().get_node("Main/Table").new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if !get_tree().get_root().get_node("Main/GUI/SettingsMenu").visible:
		if event.is_action_pressed("New Game"):
			get_tree().get_root().get_node("Main/Table").new_game()
