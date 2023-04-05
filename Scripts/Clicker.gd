extends Node2D


var click_all = false
var ignore_unclickable = true
var params

func _ready():
	params = PhysicsPointQueryParameters2D.new()
	params.set_collide_with_areas(true)
	params.set_collide_with_bodies(false)
	#params.set_collision_mask(2)


func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT: # Left mouse click
		var shapes = get_world_2d().direct_space_state.intersect_point(params)

		for shape in shapes:
			print("inside the singleton " + str(shape))
			if shape["collider"].has_method("on_click"):
				shape["collider"].on_click()
				
				if !click_all and ignore_unclickable:
					break # Thus clicks only the topmost clickable
			
			if !click_all and !ignore_unclickable:
				break # Thus stops on the first shape
