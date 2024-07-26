# unofficial_fluxx
Implementation of a card game in Godot 

Sprites and game concept are not open source - they are property of Looney Labs. Card game code in Godot Script is however. I am not likley going to continue working on this project - unless others are interested and want to calaborate. My main purpose in opening this repo is as an example of how to implement a card game in Godot. 

Sorry for the lack of comments - I am working on adding those at the moment.

## How to draw cards:

If you want to try it out - just know that you need to press the ` key (to the left of 1 on US keyboards - the one that does ~ with the shift key) 

This will open up the debug menu - where you can enter the player number and press the turn button to take turns. 

This functionality is meant to be built into the main game loop later, but at this point its in the debug menu for testing purposes.

## Current State and Future Plans:

Currently the basic mechanics of the dealing cards/ playing all 4 cards types (rules, actions, keepers, and goals) has been implemented. But the main game loop is not yet implemented. 

This was meant to be playable offline or online - but there is no net code written yet - I was attempting to carefully set up the offline game functions, so it could be controled by server responses later on.
