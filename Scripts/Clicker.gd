# Originally found at https://godotengine.org/qa/89677/solved-with-solution-how-to-click-only-the-top-area2d

extends Node2D

var params
var table

func _ready():
	params = PhysicsPointQueryParameters2D.new()
	params.set_collide_with_areas(true)
	params.set_collision_mask(2)
	table = get_tree().get_root().get_node("Main/Table")


func _input(event):
	if !get_tree().get_root().get_node("Main/GUI/SettingsMenu").visible and ((event is InputEventMouseButton and event.pressed and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT)) or (event is InputEventScreenTouch)):
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
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				top_card.on_click()
			if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT) or (event is InputEventScreenTouch and !event.pressed):
				top_card.on_click(true)
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
			table.auto_move()
