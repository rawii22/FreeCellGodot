# FreeCell
The game FreeCell implemented with Godot!

<img src="./freecellicon.png" width="200"/>

Ricardo Romanach 2023

[FreeCellGodot - GitHub](https://github.com/rawii22/FreeCellGodot)

## Contents

1. [The Game](#the-game)
	- [Background](#background)
	- [Rules](#rules)
1. [Features](#features)
	- [Gameplay](#gameplay)
	- [Custom Gameplay](#custom-gameplay)
1. [Shortcuts](#shortcuts)
1. [Implementation Notes](#implementation-notes)
1. [Potential Issues](#potential-issues)
1. [Credits](#credits)
1. [Very Special Thanks](#very-special-thanks)

## The Game

### Background

The game FreeCell is only one of the many variations of the eternal solitaire format. The immediate predecessors to FreeCell are considered to be Baker's Game and Eight Off. In Baker's Game, stacks are built down by suit instead of alternating color. This slight difference makes Baker's Game more difficult than FreeCell. The vast majority of FreeCell deals are solvable which is uncommon in the solitaire world. FreeCell is what is known as an *open* solitaire game where all the cards are visible from the start.

### Rules

The **objective** is to move all cards to the foundation in ascending order, from Ace to King, by suit.
- **Free cells**: You are provided with 4 holding cells. Each can only hold one card at a time.
- **Columns**: *Any* card can be placed in an empty column slot. You are not restricted to placing Kings in empty columns like in Klondike solitaire.
- **Stacks**: Cards can be stacked in descending order and alternating in color.
	- **Limitations**: The number of cards in a stack that can be moved is determined by the number of open cells on the table. The number of cards that can moved at a time is as follows:
		- **`(2 ^ number of empty columns) x (number of empty holding cells + 1)`**
	- When attempting to place a stack of cards onto an empty column cell, the number should be halved **halved** before you place it.

> Check out this [Wikipedia page](https://en.wikipedia.org/wiki/FreeCell) for more information on history, variations, and statistical analysis.

## Features

### Gameplay

- **Right clicking on a card** will automatically move it to another location. It will attempt to move to another location in this order: foundation, occupied columns, open columns, free cells. If none of these locations are available, it will not move.
- By **right clicking anywhere on the table**, the game will look for any card that can be moved to the foundation and, if possible, move it to the foundation automatically.
- **Auto-complete**: Once the game detects that you have won, it will offer the option to auto complete. If you reject auto-complete, you can always trigger it again by clicking on the check button on the left of the play area.
- **Numbered Deals**: By opening the menu, you can specify the desired deal number in the "New Game" button. Hit enter or click on the button after typing in the number (0-9999999) and the respective deal will be drawn. You can also click on the little "?" button to have a random number selected for you. Clicking the "New Numbered Game" button on the win screen will start a random *numbered* game.
	> **NOTE**: The numbered deals in this implementation of the game should match those of most other FreeCell games. It is based on the original Microsoft random number generator. I found a lot of help with how to do this [here](https://rosettacode.org/wiki/Deal_cards_for_FreeCell), [here](http://solitairelaboratory.com/mshuffle.txt), and [here](http://solitairelaboratory.com/fcfaq.html)
- **Save Data**: Statistics on games played are persistent. Pressing `I` will open the information screen which will show you your statistics.
- **Touch Screen Compatible**: This game should work on touch screen devices. When a card is tapped, it will do the same thing as a right-click. Dragging works the same as dragging with the mouse. Buttons are visible on the screen to make Undo, Redo, and Replay easy to access.

### Custom Gameplay

- **Move History**: After completing a game, by clicking on the button on the top left of the win screen, you have the option to view a list of the moves you made. You can also choose to watch a simulation of the game you just played. The simulation will play through all the moves you made one by one excluding any undo's and redo's you may have used. Clicking on the auto complete button during a simulation will skip to the end.
- **Custom Games**: To open the custom game screen, click on the "2023" next to my name when you open settings. You can also click on the "Custom Game" button on the information screen.
	> **TRICK**: For keyboard oriented use, pressing "tab" after moving the selected card slot will move the focus to the card selection area. After hitting "enter" in the card selection area or clicking "tab" again, the focus will move back to the card slot area. For another fast trick, use the arrow keys to change which card slot is selected, and then click on the card you want in that slot from the card selection area on the left.
- **Simulations**: Something that goes hand-in-hand with the custom game feature is the ability to simulate gameplay by specifying a list of moves. From the custom game screen, you can add a move set to a valid hand. As long as the moves are sufficient and valid, the game will play through the moves one by one. An invalid move or insufficient number of moves will cause the simulation to cease, and the game board will become playable.
	- Moves must be specified in a particular format. The value must come first: 2-9, or A for ace, T for 10, J for Jack, Q for Queen, K for King. Next must come the suit: S for spades, C for clubs, D for diamonds, H for hearts. Next comes an arrow pointing to the destination "->". Then comes the location as Column#, FreeCell#, or Foundation#, where the "#" should be replaced with 1-8 for columns or 1-4 for free cells or foundation slots. Here are some examples:
		- `AS->Foundation1`
		- `2S->FreeCell1`
		- `7D->Foundation4`
		- `TC->Column7`
		- `QH->FreeCell4`

## Shortcuts

- **`Ctrl+Z`**: Undo a move. Making a move after undoing will clear out the redo stack.
- **`Ctrl+Y`**: Redo a move.
- **`Ctrl+R`**: Replay the current hand.
- **`F2`**: Start a random game.
- **`F3`**: Start a random numbered deal.
- **`Esc`** or **`S`**: Open the settings menu.
- **`Ctrl+F`**: Toggle full screen.
- **`I`**: Open the information screen.

## Implementation Notes

For the sake of keeping things as generic as possible, each area (columns, free cells, foundation slots) has these 4 functions:

- `add_card`
	- Receives an array of cards. Returns nothing. Places the card(s) in the list into the respective area.
		- The Column area is an exception since it is capable of receiving a single card object at a time. This is because when cards are being dealt to the columns, they are added as single cards. When cards are being moved back and forth during gameplay, they are added as stacks.
- `remove_card`
	- Receives a single card object. Returns a list of cards. For columns, a list of all cards under the specified card, if any, will be returned. For the other two areas, an array with the single specified card will be returned. This function, as opposed to get_card_stack, will actually change internal properties of the parent area.
- `get_card_stack`
	- Receives a single card object. Returns a list of cards. It does the same thing as remove_card, however nothing internally is changed. This is used as a what-if function when card.gd is checking if a stack of cards can be dragged or not.
- `can_place_card`
	- Received a list of cards. Returns a boolean. If the card(s) in the list can be placed in the respective area, it will return true.

## Potential Issues

- When playing the game with a **touchscreen and on a windows computer**, if you tap and hold a card to perform a touchscreen right-click, Windows will send two signals. A general **Touch event** will trigger, and also a right-click **Mouse  event** will trigger, causing two cards to move at the same time. The current solution is to try to avoid right-clicking via touch.

	- My theory is that this will be a problem on any computer/device that attempts to emulate a right click via touch. I don't think there's much that can be done about this unless I add a cooldown between card moves. Such a cooldown would have to apply to both mouse and touch events since there's no way to distinguish between an *emulated* right-click mouse event and a *real* right-click mouse event.

## Credits

[rawii22](https://github.com/rawii22/FreeCellGodot)

## Very Special Thanks

[MiniMage7](https://github.com/MiniMage7)
