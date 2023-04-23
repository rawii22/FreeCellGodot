# FreeCellGodot
The game FreeCell implemented with Godot!


For the sake of keeping things as generic as possible, each area (columns, free cells, foundation slots) has these 4 functions:
	-add_card
		-Receives a list of cards. Returns nothing. Places the card(s) in the list into the respective area.
	-remove_card
		-Receives a single card object. Returns a list of cards. For columns, a list of all cards under the specified card, if any, will be returned. For the other two areas, an array with the single specified card will be returned. This function, as opposed to get_card_stack, will actually change internal properties of the parent area.
	-get_card_stack
		-Receives a single card object. Returns a list of cards. It does the same thing as remove_card, however nothing internally would be changed. This is used as a what-if function when card.gd is checking if a stack of cards can be dragged or not.
	-can_place_card
		-Received a list of cards. Returns a boolean. If the card(s) in the list can be placed in the respective area, it will return true.
	
	
