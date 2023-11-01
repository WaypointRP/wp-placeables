# Waypoint Placeables

![wp-placeables-screenshot](https://github.com/WaypointRP/wp-placeables/assets/18689469/292bfbd4-a531-4882-b01e-ccfdbfdcb17f)

Waypoint Placeables is a framework that provides a simple mechanism to create useable items that place interactable props into the world. Each item can be configured with the default options and can easily be extended by providing a set of custom actions. The framework provides default options for placing items, picking up items, as well as configuring items to be a pushable prop. It is designed to be easy to use and highly customizable, allowing you to create a wide range of placeable and useable items from the selection of GTA props as well as custom props.

Players can use the placeable props in a variety of ways to enhance their RP scenarios. Some examples include: building a construction site scene, creating a campsite in the woods with tents, chairs and campfires, blocking off roads for a crime scene, placing items in the world to push around to increase the realism of a scene, and much more.

Preview: https://www.youtube.com/watch?v=nLiac1VYjxE

### Overview:
- Player uses the item and the item placement mode is triggered
- A client side only (non-networked) prop is spawned and the player chooses where to place the prop
- After confirming the placement, the prop is spawned in as a networked prop so that all clients can see it and the item is removed from the player's inventory
- Players can interact with the prop using target to view the available options
- Players can place down multiple props to build a unique scene to enhance their RP scenarios
- When the player is done, they can clean up the scene by picking up the props and the item is given to the player (this is a default option that comes with all of the items)
- If an item is pushable and/or sitable, a player can stop interacting with the item by pressing 'E' (by default).
- While a player is pushing an item, a thread will run to check if something (like walking through a door, stumble animation, etc) caused them to break out of the pushing animation and will stick them back in the animation
- Adding a prop model to the config also enables world spawned props of the same model to be able to be picked up (ex: shopping carts that naturally spawn at mallmart can be picked up)
- Placed props do not persist through server restart. This script is intended to provide short term, temporary scenes per server session. 

## Placement Mode
When in placement mode, the player is able to position the prop in a radius around them. They can control its location, rotation, and height. 
- E - Places the prop in its current position
- Shift + E - Attempts to snap the prop to the ground
- Scroll Wheel Up/Down - Rotates the item
- Shift + Scroll Wheel Up/Down - Raises or lowers the item
- Right click / backspace - Exit placement mode without placing the item

> While in placement mode the script will run at about 0.09ms - 0.1ms. This is primarily because we are using Raycast natives and have to run a quick thread to capture all of the players keypresses and movements. As soon as placement mode is exited, the script will return to 0.0ms.

## Performance
This script was written with performance in mind and has been tested with 100+ props in the world with no noticeable performance impact.

Resource monitor results:
- Idle: 0.0ms
- In item placement mode: 0.09ms - 0.1ms (primarily due to raycast natives and thread to capture keypresses)
- Pushing an object: 0.2ms (thread checking that push animation is still active)

## Setup
1. Enable the script in your server.cfg
2. Add the items to your items.lua file
    <details>
    <summary>Items</summary>

        ```lua
        ------------------
        -- PLACEABLE ITEMS
        ------------------
        -- Construction items
        ["roadworkbarrier"] 		= {["name"] = "roadworkbarrier",        ["label"] = "Road Work Ahead Barrier", 			["weight"] = 1000, 		["type"] = "item", 		["image"] = "roadworkahead.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A construction 'Road Work Ahead' barrier"},
        ["roadclosedbarrier"] 		= {["name"] = "roadclosedbarrier",      ["label"] = "Road Closed Barrier", 			    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "roadclosedbarrier.png", 	["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A construction 'Road Closed' barrier"},
        ["constructionbarrier"] 	= {["name"] = "constructionbarrier",    ["label"] = "Fold-out Barrier",                 ["weight"] = 500, 		["type"] = "item", 		["image"] = "constructionbarrier.png",  ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A small construction barrier"},
        ["constructionbarrier2"]    = {["name"] = "constructionbarrier2",   ["label"] = "Construction Barrier", 	        ["weight"] = 1000, 		["type"] = "item", 		["image"] = "constructionbarrier2.png", ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A medium-sized construction barrier"},
        ["constructionbarrier3"]    = {["name"] = "constructionbarrier3",   ["label"] = "Construction Barrier", 	        ["weight"] = 1000, 		["type"] = "item", 		["image"] = "constructionbarrier3.png", ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A medium-sized construction barrier"},
        ["roadconebig"] 		    = {["name"] = "roadconebig",            ["label"] = "Road Cone Big", 			        ["weight"] = 500, 		["type"] = "item", 		["image"] = "roadconebig.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A big road cone"},
        ["roadcone"] 		        = {["name"] = "roadcone",               ["label"] = "Road Cone", 			            ["weight"] = 500, 		["type"] = "item", 		["image"] = "roadcone.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A road cone"},
        ["roadpole"] 		        = {["name"] = "roadpole",               ["label"] = "Road Pole", 			            ["weight"] = 500, 		["type"] = "item", 		["image"] = "roadpole.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A road pole"},
        ["worklight"] 		        = {["name"] = "worklight",              ["label"] = "Work light stand", 			    ["weight"] = 500, 		["type"] = "item", 		["image"] = "worklight.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A tall worklight"},
        ["worklight2"] 		        = {["name"] = "worklight2",             ["label"] = "Work light stand", 			    ["weight"] = 500, 		["type"] = "item", 		["image"] = "worklight2.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A tall worklight"},
        ["worklight3"] 		        = {["name"] = "worklight3",             ["label"] = "Work light", 			            ["weight"] = 500, 		["type"] = "item", 		["image"] = "worklight3.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A worklight"},
        ["constructiongenerator"]   = {["name"] = "constructiongenerator",  ["label"] = "Construction Generator", 			["weight"] = 2000, 		["type"] = "item", 		["image"] = "constructiongenerator.png",["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A generator with lights"},
        ["trafficdevice"]           = {["name"] = "trafficdevice",          ["label"] = "Traffic Device (Left)", 			["weight"] = 1000, 		["type"] = "item", 		["image"] = "trafficdevice.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A traffic sign with an arrow pointing left"},
        ["trafficdevice2"]          = {["name"] = "trafficdevice2",         ["label"] = "Traffic Device (Right)", 			["weight"] = 1000, 		["type"] = "item", 		["image"] = "trafficdevice.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A traffic sign with an arrow pointing right"},
        ["meshfence1"]              = {["name"] = "meshfence1",             ["label"] = "Mesh Fence Small", 			    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "meshfence.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A small mesh construction fence"},
        ["meshfence2"]              = {["name"] = "meshfence2",             ["label"] = "Mesh Fence Medium", 			    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "meshfence.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A medium mesh construction fence"},
        ["meshfence3"]              = {["name"] = "meshfence3",             ["label"] = "Mesh Fence Large", 			    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "meshfence.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A large mesh construction fence"},
        ["waterbarrel"]             = {["name"] = "waterbarrel",            ["label"] = "Water Barrel", 			        ["weight"] = 500, 		["type"] = "item", 		["image"] = "waterbarrel.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A construction barrel full of water"},
        -- Homeless / camping items
        ["tent"]                    = {["name"] = "tent",                   ["label"] = "Old Tent", 			            ["weight"] = 1000, 		["type"] = "item", 		["image"] = "oldtent.png", 		        ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "An old tent with several patches on it"},
        ["tent2"]                   = {["name"] = "tent2",                  ["label"] = "Tent", 			                ["weight"] = 1000, 		["type"] = "item", 		["image"] = "tent.png", 		        ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A camping tent"},
        ["tent3"]                   = {["name"] = "tent3",                  ["label"] = "Large Tent", 			            ["weight"] = 2000, 		["type"] = "item", 		["image"] = "largetent.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A large party tent"},
        ["sleepingbag"]             = {["name"] = "sleepingbag",            ["label"] = "Sleeping Bag", 			        ["weight"] = 1000, 		["type"] = "item", 		["image"] = "sleepingbag.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A sleeping bag rated for 20F"},
        ["hobostove"]               = {["name"] = "hobostove",              ["label"] = "Hobo Stove", 			            ["weight"] = 1000, 		["type"] = "item", 		["image"] = "hobostove.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A burn barrel"},
        ["campfire"]                = {["name"] = "campfire",               ["label"] = "Camp Fire", 			            ["weight"] = 1000, 		["type"] = "item", 		["image"] = "campfire.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Bundle of logs and kindling to make a camp fire"},
        ["hobomattress"]            = {["name"] = "hobomattress",           ["label"] = "Hobo Mattress", 			        ["weight"] = 1000, 		["type"] = "item", 		["image"] = "hobomattress.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "An old, stained mattress"},
        ["hoboshelter"]             = {["name"] = "hoboshelter",            ["label"] = "Hobo Shelter", 			        ["weight"] = 1000, 		["type"] = "item", 		["image"] = "hoboshelter.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A cardboard homeless shelter"},
        ["canopy1"]                 = {["name"] = "canopy1",                ["label"] = "Canopy (Green)", 			        ["weight"] = 1000, 		["type"] = "item", 		["image"] = "canopy.png", 		        ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A green popup canopy"},
        ["canopy2"]                 = {["name"] = "canopy2",                ["label"] = "Canopy (Blue)", 			        ["weight"] = 1000, 		["type"] = "item", 		["image"] = "canopy.png", 		        ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A blue popup canopy"},
        ["canopy3"]                 = {["name"] = "canopy3",                ["label"] = "Canopy (White)", 			        ["weight"] = 1000, 		["type"] = "item", 		["image"] = "canopy.png", 		        ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A white popup canopy"},
        ["cot"]                     = {["name"] = "cot",                    ["label"] = "Cot", 			                    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "cot.png", 		            ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A camping cot"},

        -- Triathlon items
        ["tristarttable"]           = {["name"] = "tristarttable",          ["label"] = "Triathlon Start Table", 			["weight"] = 1000, 		["type"] = "item", 		["image"] = "tristarttable.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Triathlon check in desk"},
        ["tristartbanner"]          = {["name"] = "tristartbanner",         ["label"] = "Triathlon Start Banner", 			["weight"] = 1000, 		["type"] = "item", 		["image"] = "tristartbanner.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Triathlon start banner"},
        ["trifinishbanner"]         = {["name"] = "trifinishbanner",        ["label"] = "Triathlon Finish Banner", 			["weight"] = 1000, 		["type"] = "item", 		["image"] = "trifinishbanner.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Triathlon finish banner"},

        -- Tables
        ["plastictable"]            = {["name"] = "plastictable",           ["label"] = "Plastic Table (Collapsible)", 		["weight"] = 1000, 		["type"] = "item", 		["image"] = "plastictable.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Simple portable plastic table"},
        ["plastictable2"]           = {["name"] = "plastictable2",          ["label"] = "Plastic Table", 			        ["weight"] = 1000, 		["type"] = "item", 		["image"] = "plastictable.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Simple portable plastic table"},
        ["woodtable"]               = {["name"] = "woodtable",              ["label"] = "Small Wood Table", 			    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "woodtable.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Small portable wood table"},
        ["woodtable2"]              = {["name"] = "woodtable2",             ["label"] = "Wood Table", 			            ["weight"] = 1000, 		["type"] = "item", 		["image"] = "woodtable.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Portable wood table"},

        -- Beach items
        ["beachtowel"]              = {["name"] = "beachtowel",             ["label"] = "Beach towel", 			            ["weight"] = 500, 		["type"] = "item", 		["image"] = "beachtowel.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A towel for the beach"},
        ["beachumbrella"]           = {["name"] = "beachumbrella",          ["label"] = "Beach umbrella", 			        ["weight"] = 500, 		["type"] = "item", 		["image"] = "beachumbrella.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A beach umbrella (white and blue)"},
        ["beachumbrella2"]          = {["name"] = "beachumbrella2",         ["label"] = "Beach umbrella", 			        ["weight"] = 500, 		["type"] = "item", 		["image"] = "beachumbrella.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A beach umbrella (green, white, blue)"},
        ["beachumbrella3"]          = {["name"] = "beachumbrella3",         ["label"] = "Beach umbrella", 			        ["weight"] = 500, 		["type"] = "item", 		["image"] = "beachumbrella.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A beach umbrella (white)"},
        ["beachumbrella4"]          = {["name"] = "beachumbrella4",         ["label"] = "Beach umbrella", 			        ["weight"] = 500, 		["type"] = "item", 		["image"] = "beachumbrella.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A beach umbrella (blue)"},
        ["beachball"]               = {["name"] = "beachball",              ["label"] = "Beach ball", 			            ["weight"] = 200, 		["type"] = "item", 		["image"] = "beachball.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A beach ball"},

        -- Chairs
        ["camp_chair_green"] 			 = {["name"] = "camp_chair_green", 			    ["label"] = "Camp chair (green)", 		["weight"] = 1000, 		["type"] = "item", 		["image"] = "campchair_green.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A lightweight, collapsible chair"},
        ["camp_chair_blue"] 			 = {["name"] = "camp_chair_blue", 			    ["label"] = "Camp chair (blue)", 		["weight"] = 1000, 		["type"] = "item", 		["image"] = "campchair_blue.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A lightweight, collapsible chair"},
        ["camp_chair_plaid"] 			 = {["name"] = "camp_chair_plaid", 			    ["label"] = "Camp chair (plaid)", 		["weight"] = 1000, 		["type"] = "item", 		["image"] = "campchair_plaid.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A lightweight, collapsible chair"},
        ["plastic_chair"] 			     = {["name"] = "plastic_chair", 			    ["label"] = "Plastic chair", 		    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "plastic_chair.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A lightweight, plastic chair"},
        ["folding_chair"] 			     = {["name"] = "folding_chair", 			    ["label"] = "Folding chair", 		    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "folding_chair.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A lightweight, folding chair"},

        -- Misc
        ["greenscreen"]             = {["name"] = "greenscreen",            ["label"] = "Green Screen Set", 			    ["weight"] = 2000, 		["type"] = "item", 		["image"] = "greenscreen.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A green screen production set"},
        ["ropebarrier"]             = {["name"] = "ropebarrier",            ["label"] = "Rope Barrier", 			        ["weight"] = 500, 		["type"] = "item", 		["image"] = "ropebarrier.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A rope barrier"},
        ["largesoccerball"]         = {["name"] = "largesoccerball",        ["label"] = "Large Soccer ball", 			    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "soccerball.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A large soccer ball"},
        ["soccerball"]              = {["name"] = "soccerball",             ["label"] = "Soccer ball", 			            ["weight"] = 200, 		["type"] = "item", 		["image"] = "soccerball.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A soccer ball"},
        ["ramp1"]                   = {["name"] = "ramp1",                  ["label"] = "Wood Ramp (Gradual)", 			    ["weight"] = 25000, 		["type"] = "item", 		["image"] = "woodramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A ramp with a slight incline"},
        ["ramp2"]                   = {["name"] = "ramp2",                  ["label"] = "Wood Ramp (Moderate)", 			["weight"] = 25000, 		["type"] = "item", 		["image"] = "woodramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A ramp with a moderate incline"},
        ["ramp3"]                   = {["name"] = "ramp3",                  ["label"] = "Wood Ramp (Steep)", 			    ["weight"] = 25000, 		["type"] = "item", 		["image"] = "woodramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A ramp with a steep incline"},
        ["ramp4"]                   = {["name"] = "ramp4",                  ["label"] = "Metal Ramp (Large)", 			    ["weight"] = 50000, 		["type"] = "item", 		["image"] = "metalramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A large metal ramp with a moderate incline"},
        ["ramp5"]                   = {["name"] = "ramp5",                  ["label"] = "Metal Trailer Ramp", 			    ["weight"] = 25000, 		["type"] = "item", 		["image"] = "metalramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A metal trailer ramp with a moderate incline"},
        ["skateramp"]               = {["name"] = "skateramp",              ["label"] = "Skate ramp", 			            ["weight"] = 50000, 		["type"] = "item", 		["image"] = "skateramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A skate ramp"},
        ["stuntramp1"]              = {["name"] = "stuntramp1",             ["label"] = "Stunt ramp S", 			        ["weight"] = 30000, 		["type"] = "item", 		["image"] = "stuntramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A short stunt ramp"},
        ["stuntramp2"]              = {["name"] = "stuntramp2",             ["label"] = "Stunt ramp M", 			        ["weight"] = 30000, 		["type"] = "item", 		["image"] = "stuntramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A medium stunt ramp"},
        ["stuntramp3"]              = {["name"] = "stuntramp3",             ["label"] = "Stunt ramp L", 			        ["weight"] = 30000, 		["type"] = "item", 		["image"] = "stuntramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A large stunt ramp"},
        ["stuntramp4"]              = {["name"] = "stuntramp4",             ["label"] = "Stunt ramp XL", 			        ["weight"] = 30000, 		["type"] = "item", 		["image"] = "stuntramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A extra large stunt ramp"},
        ["stuntramp5"]              = {["name"] = "stuntramp5",             ["label"] = "Stunt ramp XXL", 			        ["weight"] = 30000, 		["type"] = "item", 		["image"] = "stuntramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A XXL stunt ramp"},
        ["stuntloop1"]              = {["name"] = "stuntloop1",             ["label"] = "Stunt half loop", 			        ["weight"] = 30000, 		["type"] = "item", 		["image"] = "stuntramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A stunt half loop"},
        ["stuntloop2"]              = {["name"] = "stuntloop2",             ["label"] = "Stunt loop", 			            ["weight"] = 30000, 		["type"] = "item", 		["image"] = "stuntramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A stunt full loop"},
        ["stuntloop3"]              = {["name"] = "stuntloop3",             ["label"] = "Stunt spiral", 			        ["weight"] = 30000, 		["type"] = "item", 		["image"] = "stuntramp.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A stunt full loop"},
        ["stepladder"] 			    = {["name"] = "stepladder", 			["label"] = "Step ladder", 			            ["weight"] = 1000, 		    ["type"] = "item", 		["image"] = "stepladder.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Used to reach higher places"},
        ["trafficlight"] 			= {["name"] = "trafficlight", 			["label"] = "Traffic Light", 			        ["weight"] = 1000, 		    ["type"] = "item", 		["image"] = "trafficlight.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A deployable traffic control device"},
        ["sexdoll"] 			 	= {["name"] = "sexdoll", 				["label"] = "Sex doll", 						["weight"] = 1000, 			["type"] = "item", 		["image"] = "sexdoll.png", 				["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A deflated mini-sex doll"},
        
        -- Medical items
        ["medbag"] 			 		= {["name"] = "medbag", 				["label"] = "Medical Bag", 						["weight"] = 1000, 			["type"] = "item", 		["image"] = "medbag.png", 				["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A medical bag"},
        ["examlight"] 			 	= {["name"] = "examlight", 				["label"] = "Exam Light", 						["weight"] = 1000, 			["type"] = "item", 		["image"] = "examlight.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A medical exam light"},
        ["hazardbin"] 			 	= {["name"] = "hazardbin", 				["label"] = "Hazard Wastebin", 					["weight"] = 1000, 			["type"] = "item", 		["image"] = "hazardbin.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A hazardous waste bin"},
        ["microscope"] 			 	= {["name"] = "microscope", 			["label"] = "Microscope", 						["weight"] = 1000, 			["type"] = "item", 		["image"] = "microscope.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "Make small things big"},
        ["oscillator"] 				= {["name"] = "oscillator", 			["label"] = "Oscillator", 						["weight"] = 1000, 			["type"] = "item", 		["image"] = "oscillator.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A heart beat monitor"},
        ["medmachine"] 				= {["name"] = "medmachine", 			["label"] = "Medical Machine", 					["weight"] = 1000, 			["type"] = "item", 		["image"] = "medmachine.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A medical machine"},
        ["hospitalbedtable"] 		= {["name"] = "hospitalbedtable", 		["label"] = "Bedside Table", 					["weight"] = 1000, 			["type"] = "item", 		["image"] = "hospitalbedtable.png", 	["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A hospital bedside table"},
        ["medtable"] 			 	= {["name"] = "medtable", 				["label"] = "Medical Table", 					["weight"] = 1000, 			["type"] = "item", 		["image"] = "medtable.png", 			["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A medical table with machines on it"},
        ["bodybag"] 			 	= {["name"] = "bodybag", 				["label"] = "Body Bag", 						["weight"] = 1000, 			["type"] = "item", 		["image"] = "bodybag.png", 				["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A body bag for putting deceased humans in"},
        
        -- Pushables
        ["shoppingcart1"] 				 = {["name"] = "shoppingcart1", 				["label"] = "Shopping Cart (Empty)", 	["weight"] = 1000, 		["type"] = "item", 		["image"] = "shoppingcart.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "An empty, plastic shopping cart"},
        ["shoppingcart2"] 				 = {["name"] = "shoppingcart2", 				["label"] = "Shopping Cart (Full)", 	["weight"] = 1000, 		["type"] = "item", 		["image"] = "shoppingcart.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A full plastic shopping cart"},
        ["shoppingcart3"] 				 = {["name"] = "shoppingcart3", 				["label"] = "Shopping Cart (Empty)", 	["weight"] = 1000, 		["type"] = "item", 		["image"] = "shoppingcart.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "An empty, metal shopping cart"},
        ["shoppingcart4"] 				 = {["name"] = "shoppingcart4", 				["label"] = "Shopping Cart (Full)", 	["weight"] = 1000, 		["type"] = "item", 		["image"] = "shoppingcart.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A full metal shopping cart"},
        ["wheelbarrow"] 				 = {["name"] = "wheelbarrow", 				    ["label"] = "Wheelbarrow", 	            ["weight"] = 1000, 		["type"] = "item", 		["image"] = "wheelbarrow.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Useful for moving materials"},
        ["warehousetrolly1"] 		     = {["name"] = "warehousetrolly1", 				["label"] = "Warehouse Trolly (Empty)", ["weight"] = 1000, 		["type"] = "item", 		["image"] = "warehousetrolly1.png",     ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Industrial warehouse trolly"},
        ["warehousetrolly2"] 		     = {["name"] = "warehousetrolly2", 				["label"] = "Warehouse Trolly (Full)", 	["weight"] = 1000, 		["type"] = "item", 		["image"] = "warehousetrolly2.png", 	["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Industrial warehouse trolly with a box on it"},
        ["roomtrolly"] 		             = {["name"] = "roomtrolly", 				    ["label"] = "Room Trolly", 	            ["weight"] = 1000, 		["type"] = "item", 		["image"] = "roomtrolly.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Room service cart"},
        ["janitorcart1"] 		         = {["name"] = "janitorcart1", 				    ["label"] = "Janitor Cart", 	        ["weight"] = 1000, 		["type"] = "item", 		["image"] = "janitorcart1.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A janitorial cart with cleaning supplies"},
        ["janitorcart2"] 		         = {["name"] = "janitorcart2", 				    ["label"] = "Janitor Cart", 	        ["weight"] = 1000, 		["type"] = "item", 		["image"] = "janitorcart2.png", 		["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A Diamond Casino janitorial cart with cleaning supplies"},
        ["mopbucket"] 		             = {["name"] = "mopbucket", 				    ["label"] = "Mop Bucket", 	            ["weight"] = 500, 		["type"] = "item", 		["image"] = "mopbucket.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A mop bucket with cleaning solution"},
        ["metalcart"] 		             = {["name"] = "metalcart", 				    ["label"] = "Metal Cart", 	            ["weight"] = 1000, 		["type"] = "item", 		["image"] = "metalcart.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "An empty metal cart"},
        ["teacart"] 		             = {["name"] = "teacart", 				        ["label"] = "Tea Cart", 	            ["weight"] = 1000, 		["type"] = "item", 		["image"] = "teacart.png", 		        ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "An empty tea cart"},
        ["drinkcart"] 		             = {["name"] = "drinkcart", 				    ["label"] = "Drink Cart", 	            ["weight"] = 1000, 		["type"] = "item", 		["image"] = "drinkcart.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "An empty drink cart"},
        ["handtruck1"] 		             = {["name"] = "handtruck1", 				    ["label"] = "Hand Truck", 	            ["weight"] = 1000, 		["type"] = "item", 		["image"] = "handtruck.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "An empty hand truck"},
        ["handtruck2"] 		             = {["name"] = "handtruck2", 				    ["label"] = "Hand Truck (boxes)", 	    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "handtruck.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A hand truck with boxes"},
        ["trashbin"] 			         = {["name"] = "trashbin", 			            ["label"] = "Trash Bin", 			    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "trashbin.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Trash bin"},
        ["lawnmower"] 			         = {["name"] = "lawnmower", 			        ["label"] = "Lawnmower", 			    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "lawnmower.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "Cuts grass"},
        ["toolchest"] 			         = {["name"] = "toolchest", 			        ["label"] = "Tool Chest", 			    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "toolchest.png", 		    ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A sturdy toolchest"},
        ["carjack"] 			         = {["name"] = "carjack", 			            ["label"] = "Car jack", 			    ["weight"] = 1000, 		["type"] = "item", 		["image"] = "carjack.png", 		        ["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,    ["combinable"] = nil,   ["description"] = "A car jack"},
        -----------------------
        -- END OF PLACEABLES --
        -----------------------
        ```
    </details>
3. Add the images from `/images` to your inventory scripts
4. Add a way for players to acquire these new items (ex: add them to a shop, make them craftable, rewards for jobs, etc)
5. If you want an item to be useable by players that are dead (such as a hospitalbed), you will need to make an update to qb-ambulancejob. Ambulancejob script has a thread that will continually run to put you back into the death animation. Look for the thread that has a check for `if not IsEntityPlayingAnim(ped, deadAnimDict, deadAnim, 3) then` and update it to the following:
    ```lua
        -- This resets the player back into the dead animation and runs it on a fast loop
        -- If the player is sitting on a placeable prop, we dont want to reset the animation or it will kick them off of the prop
        if (
            not exports['wp-placeables']:IsPlayerSittingOnPlaceableProp() and 
            not IsEntityPlayingAnim(ped, deadAnimDict, deadAnim, 3)
        ) then
            loadAnimDict(deadAnimDict)
            TaskPlayAnim(ped, deadAnimDict, deadAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
        end
    ```
6. If using a framework other than QBCore or ESX, you can use the framework.lua file to add the framework specific implementations. Feel free to submit a PR to get support for your framework added to the main repo, so others can leverage it as well.

## Adding a new placeable item
If you want to add or modify a placeable item, follow the below instructions.

1. First determine what prop(s) you want to add. It is recommended to use a site such as [Pleb Masters: Forge](https://forge.plebmasters.de/objects) to find props and the model names.
2. Add the new item to your items.lua file as you normally would
    - Make sure to include the following additional fields:
        - `['model'] = "<propModelName>"` - this is the model of the prop that will be spawned
        - `['isFrozen'] = <true/false>` - whether or not the prop will be frozen in place when it is spawned
        - `['shouldUseItemNameState'] = <true/false>` - if you intend to use the same prop model for multiple items, then you will need to set this as true, otherwise you do not need to define this. AddTargetModel only supports one set of options per model, so this flag is necessary to use a statebag property instead.
3. Add the item to the `Config.PlaceableProps` in config.lua
    - If the prop is just a simple prop with no custom options then all you need to do is add: `{item = "<itemName>", model = "<propModelName>"}`.
    - If you want to put custom actions on the prop, then you will also need to include the `customTargetOptions`.
        ```lua
        local exampleCustomTargetOptions = {
            event = "someScript:client:exampleEvent",
            icon = "fas fa-chair",
            label = "Example action",
        }

        {item = "<itemName>", model = "<propModelName>", customTargetOptions = exampleCustomTargetOptions}
        ```
    - If you want to add custom action on pickup of the prop, you can add a `customPickupEvent`. Simply provide the name of the event that you want to call when the prop is picked up. _Most scenarios will not need this, but it is available if you need it._
        ```lua
        {item = "<itemName>", model = "<propModelName>", customPickupEvent = "someScript:client:customPickupEvent"}

        RegisterNetEvent('someScript:client:customPickupEvent', function(data)
            -- Your custom logic goes here

            -- Use this event to handle the default pickup logic (removing prop, giving item back to player, etc)
            TriggerEvent('wp-placeables:client:pickUpItem', data)
        end)
        ```
    - If you want the item to be a pushable object, utilize the default `pushTargetOptions`. If you also want the object to have the option to sit on it use `pushAndSitTargetOptions`. Most likely you will need to override the offset, rotation, and potentially the animations. Use the `setCustomTargetOptions()` helper function to override only the values you need and the rest will be copied. Reference the existing pushable objects to see how this is done. 
        ```lua
            {item = "wheelbarrow",   model = "prop_wheelbarrow01a",
                customTargetOptions = setCustomTargetOptions(
                    pushAndSitTargetOptions, {
                        offset = {x =  -0.4, y = -1.8, z = -0.6},
                        rotation = {x = 0.0, y = 20.0, z = 90.0},
                        animationDict = "missfinale_c2ig_11",
                        animationName = "pushcar_offcliff_f",
                    }, {
                        offset = {x = -0.25, y = 0.0, z = 1.4},
                        rotation = {x = 13.0, y = 0.0, z = 255.0},
                        animationDict = "anim@amb@business@bgen@bgen_no_work@",
                        animationName = "sit_phone_phoneputdown_idle_nowork",
                    }
                )
            },
        ```
> Ensure itemName and propModelName matches the item you added in step 1

## Optional
- If you want to enable logging for the placement/pickup of items, you just need to capture the logging event for `itemplacement`. We use the following event for capturing the logs: `TriggerServerEvent("qb-log:server:CreateLog", "itemplacement", "Item "..action.." By:", color, logMessage)`


## Dependencies
- QBCore / ESX / Or other frameworks (must implement framework specific solutions in framework.lua)
- QBCore / ESX / OX for Notifications
- QB-target or equivalent script

## Gallery
![wp-placeables-screenshot1](https://github.com/WaypointRP/wp-placeables/assets/18689469/0dda029f-3e62-4492-adf0-e8d77ad89994)
![wp-placeables-screenshot2](https://github.com/WaypointRP/wp-placeables/assets/18689469/7c279cff-1b0b-458b-9013-55f15dfc0a2e)
![wp-placeables-screenshot3](https://github.com/WaypointRP/wp-placeables/assets/18689469/bd2c99d7-de2c-415f-a9a4-d3946bac701b)
![wp-placeables-screenshot4](https://github.com/WaypointRP/wp-placeables/assets/18689469/71d10a9d-3140-4f36-a45c-4a8cc1130709)

## Scripts that use Waypoint Placeables
Checkout these scripts that use Waypoint Placeables!

- [Waypoint Fireworks](https://backsh00ter.tebex.io/package/5753511)
