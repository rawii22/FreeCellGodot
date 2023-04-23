# Originally found at https://godotengine.org/qa/89677/solved-with-solution-how-to-click-only-the-top-area2d

extends Node2D

var params

func _ready():
	params = PhysicsPointQueryParameters2D.new()
	params.set_collide_with_areas(true)
	params.set_collision_mask(2)


#TODO: handle touch events like right clicks, and keep mouse events like before

func _input(event):
	if event is InputEventMouseButton and event.pressed and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT): # Left mouse click
		params.position = event.position
		var shapes = get_world_2d().direct_space_state.intersect_point(params)
		var top_card
		var top_card_pos = -1
		
		for shape in shapes:
			if shape["collider"].has_method("on_click"):
				if shape["collider"].column_position > top_card_pos:
					top_card = shape["collider"]
					top_card_pos = shape["collider"].column_position
		
		if top_card_pos > -1:
			if event.button_index == MOUSE_BUTTON_LEFT:
				top_card.on_click(false)
			if event.button_index == MOUSE_BUTTON_RIGHT:
				top_card.on_click(true)
