Definition of the folder structure:
	Art: Stores anything art related, like sprites, spritesheets, fonts, textures, etc
	Assets: Actual node assets that can be used in the game
		Composition Pieces: These are helper nodes that are GENERIC - they can be added to any node, like a Godot node component
		Hurtboxes: These are the nodes that get spawned by anything that needs to deal damage (i.e. a weapon slash or an arrow)
		Items: The resources for item data that can live in the player's inventory
	Audio: The audio for the game
	Nodes: These are the larger nodes or "scenes" for the game
		Bootstrap: This is the first node that's loaded, used to tell the Core to start the game
		Core: The main director of the game. Registers the main managers and controls the game state, giving direction to the managers based on that
		Sandbox: Purely manages the sandbox node
		Menus: Stores all the menu nodes, like the main menu, pause menu, etc.
		UI: Stores the UI nodes that can be swapped in and out based on the game state, including the HUD
	Resources: These are any resources that never change and are globally accessed, like the ItemLibrary and the Starting Data for the player when they start a new game
	Scripts: These are all the .gd scripts in the game
