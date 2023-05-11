# Originally found at https://godotengine.org/qa/89677/solved-with-solution-how-to-click-only-the-top-area2d
#This singleton might not have been necessary if control nodes were used for the cards instead of Node2D.
#This singleton will pick up on click events, and trigger the desired functionality on the card that has
# the lowest physical column position (aka the highest value in the column_position property).

extends Node2D

var params
var table
var GUI

func _ready():
	params = PhysicsPointQueryParameters2D.new()
	params.set_collide_with_areas(true)
	params.set_collision_mask(2)
	table = get_tree().get_root().get_node("Main/Table")
	GUI = get_tree().get_root().get_node("Main/GUI")


func _input(event):
	if !table.auto_completing and !GUI.block_ui_changes and GUI.open_ui == 0 and ((event is InputEventMouseButton and event.pressed and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT)) or (event is InputEventScreenTouch)):
		params.position = event.position
		var shapes = get_world_2d().direct_space_state.intersect_point(params)
		var top_card
		var top_card_pos = -1
		
		for shape in shapes:
			if shape["collider"].has_method("on_click"):
				if shape["collider"].column_position > top_card_pos:
					top_card = shape["collider"]
					top_card_pos = shape["collider"].column_position
		
		#If a card is left clicked or dragged with touch, it will initiate dragging and defer to the card's functionality
		#If a card is right clicked with the mouse or tapped through a touchscreen, it will be auto moved to an available location. Look in card for more details.
		#If the table is right clicked with the mouse, the table will attempt to move one card to the foundation if possible.
		if top_card_pos > -1:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				top_card.on_click()
			if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT) or (event is InputEventScreenTouch and !event.pressed):
				top_card.on_click(true)
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			table.auto_move()
