Config = {}

-- Frameworks
-- Supported framework options are listed next to each option
-- If the framework you are using is not listed, you will need to modify the framework.lua code to work with your framework
-- Note: If using ox for any option, enable @ox_lib/init.lua in the manifest!

Config.Framework = 'qb'     -- 'qb', 'esx'
Config.Notify = 'qb'        -- 'qb', 'esx', 'ox' 
Config.Target = 'qb'        -- 'qb', 'ox'
Config.Inventory = 'qb'     -- 'qb', 'esx', 'ox'
Config.ProgessBar = 'qb'    -- 'qb', 'ox', 'none'
Config.Log = 'qb'           -- 'qb', 'none'

Config.ItemPlacementModeRadius = 10.0 -- Object can only be placed within this radius of the player

-- These are necessary so people can't place props far away
Config.minZOffset = -2.0 -- The min z offset for placing objects
Config.maxZOffset = 2.0 -- The max z offset for placing objects

-- Creates a deep copy of the table
-- This is necessary for getting around luas pass by reference of tables
local function deepcopy(orig) -- modified the deep copy function from http://lua-users.org/wiki/CopyTable
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if not orig.canOpen or orig.canOpen() then
            local toRemove = {}
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                if type(orig_value) == 'table' then
                    if not orig_value.canOpen or orig_value.canOpen() then
                        copy[deepcopy(orig_key)] = deepcopy(orig_value)
                    else
                        toRemove[orig_key] = true
                    end
                else
                    copy[deepcopy(orig_key)] = deepcopy(orig_value)
                end
            end
            for i=1, #toRemove do table.remove(copy, i) --[[ Using this to make sure all indexes get re-indexed and no empty spaces are in the radialmenu ]] end
            if copy and next(copy) then setmetatable(copy, deepcopy(getmetatable(orig))) end
        end
    elseif orig_type ~= 'function' then
        copy = orig
    end
    return copy
end

-- Helper function to combine default options with custom target options for items
---@param targetOptions: The default target options for the item (example pushTargetOptions for push only objects and pushAndSitTargetOptions for push and sit objects)
---@param animationPushOptions: Optional - The custom animation options for pushing the object (modifying offsets, rotations, animations)
---@param animationSitOptions: Optional - The custom animation options for sitting on the object (modifying offsets, rotations, animations)
---@param otherOptions: Optional - Any other custom target options you want to add to the item
local function setCustomTargetOptions(targetOptions, animationPushOptions, animationSitOptions, otherOptions)
    local customTargetOptions = deepcopy(targetOptions)

    if animationPushOptions then
        customTargetOptions[1].animationPushOptions = animationPushOptions
    end

    if animationSitOptions then
        customTargetOptions[2].animationSitOptions = animationSitOptions
    end

    if otherOptions then
        for i = 1, #otherOptions do
            customTargetOptions[#customTargetOptions + 1] = otherOptions[i]
        end
    end

    return customTargetOptions
end

-- Default target options

local pushAndSitTargetOptions = {
    {
        event = "wp-placeables:client:pushObject",
        icon = "fas fa-shopping-cart",
        label = "Push object",
        animationPushOptions = {
            offset = {x =  -0.4, y = -1.7, z = -0.3},
            rotation = {x = 0.0, y = 0.0, z = 180.0},
            animationDict = "missfinale_c2ig_11",
            animationName = "pushcar_offcliff_f",
        }
    },
    {
        event = "wp-placeables:client:sitOnObject",
        icon = "fas fa-chair",
        label = "Sit on object",
        animationSitOptions = {
            offset = {x = 0.0, y = 0.15, z = 0.85},
            rotation = {x = 0.0, y = 10.0, z = 175.0},
            animationDict = "anim@amb@business@bgen@bgen_no_work@",
            animationName = "sit_phone_phoneputdown_idle_nowork",
        }
    },
}

local pushTargetOptions = {
    {
        event = "wp-placeables:client:pushObject",
        icon = "fas fa-shopping-cart",
        label = "Push cart",
        animationPushOptions = {
            offset = {x =  -0.4, y = -1.7, z = -0.3},
            rotation = {x = 0.0, y = 0.0, z = 180.0},
            animationDict = "missfinale_c2ig_11",
            animationName = "pushcar_offcliff_f",
        }
    },
}

-- Define custom target options here for addon items

-- Uncomment this line if you are using wp-seats
local chairCustomTargetOptions = {
    {
        event = "wp-seats:client:sitOnChair",
        icon = "fas fa-chair",
        label = "Sit down",
    },
}

-- Uncomment this line if you are using wp-yogamats
-- local yogaCustomTargetOptions = {
--     {
--         event = "wp-yogamats:client:useYogaMat",
--         icon = "fas fa-pray",
--         label = "Do yoga",
--     },
-- }

-- Uncomment this line if you are using wp-printer
-- local printerCustomTargetOptions = {
--     {
--         event = "wp-printer:client:UsePrinter",
--         icon = "fas fa-print",
--         label = "Use printer",
--     },
-- }

-- Uncomment this line if you are using wp-fireworks
-- local fireworkCustomTargetOptions = {
--     {
--         event = 'wp-fireworks:client:lightFireworkFuse',
--         icon = "fa-solid fa-fire",
--         label = "Light fuse"
--     },
--     {
--         event = 'wp-fireworks:client:buildFireworkSequence',
--         icon = 'fa-solid fa-link',
--         label = 'Add to sequence'
--     }
-- }

-- Uncomment this line if you are using wp-trafficlights
-- local trafficLightCustomTargetOptions = {
--     {
--         event = "wp-trafficlights:client:OpenMenu",
--         icon = "fas fa-traffic-light",
--         label = "Remote control traffic light",
--     },
-- }

-- Uncomment this line if you are using wp-trafficlights
-- local trafficLightCustomPickupEvent = "wp-trafficlights:RemoveTrafficLight"

-- Add the props you want to be placeable here
-- Every prop will have the "pickup" target option added by default (to override use customPickupEvent)
-- REQUIRED FIELDS:
---@param item: The item name as defined in your items.lua
---@param label: The label to be used for this item (displayed in the progress bar)
---@param model: The prop model to be used for this item
---@param isFrozen: Whether or not the prop should be frozen in place when placed
--- OPTIONAL FIELDS:
---@param customTargetOptions: Custom target options for this item, if it should do more than just pickup
---@param customPickupEvent: If you want to override the default pickup event, set this to the event you want to be called when the "pickup" target option is used
Config.PlaceableProps = {
    -- Constructions props
    {item = "roadworkbarrier", label = "Road Work Ahead Barrier", model = "prop_barrier_work04a", isFrozen = true},
    {item = "roadclosedbarrier", label = "Road Closed Barrier", model = "xm3_prop_xm3_road_barrier_01a", isFrozen = true},
    {item = "constructionbarrier", label = "Fold-out Barrier", model = "prop_barrier_work01a", isFrozen = false},
    {item = "constructionbarrier2", label = "Construction Barrier", model = "prop_barrier_work06a", isFrozen = true},
    {item = "constructionbarrier3", label = "Construction Barrier", model = "prop_mp_barrier_02b", isFrozen = true},
    {item = "roadconebig", label = "Big Road Cone", model = "prop_barrier_wat_03a", isFrozen = false},
    {item = "roadcone", label = "Road Cone", model = "prop_roadcone01a", isFrozen = false},
    {item = "roadpole", label = "Road Pole", model = "prop_roadpole_01a", isFrozen = false},
    {item = "worklight", label = "Work Light", model = "prop_worklight_01a", isFrozen = false},
    {item = "worklight2", label = "Work Light", model = "prop_worklight_04b", isFrozen = false},
    {item = "worklight3", label = "Work Light", model = "prop_worklight_02a", isFrozen = false},
    {item = "constructiongenerator", label = "Construction Generator", model = "prop_generator_03b", isFrozen = true},
    {item = "trafficdevice", label = "Traffic Device (Left)", model = "prop_trafficdiv_01", isFrozen = true},
    {item = "trafficdevice2", label = "Traffic Device (Right)", model = "prop_trafficdiv_02", isFrozen = true},
    {item = "meshfence1", label = "Mesh Fence (Small)", model = "prop_fnc_omesh_01a", isFrozen = true},
    {item = "meshfence2", label = "Mesh Fence (Medium)", model = "prop_fnc_omesh_02a", isFrozen = true},
    {item = "meshfence3", label = "Mesh Fence (Large)", model = "prop_fnc_omesh_03a", isFrozen = true},
    {item = "waterbarrel", label = "Water Barrel", model = "prop_barrier_wat_04a", isFrozen = false},

    -- Camping + Hobo props
    {item = "tent", label = "Old Tent", model = "prop_skid_tent_03", isFrozen = true},
    {item = "tent2", label = "Tent", model = "prop_skid_tent_01", isFrozen = true},
    {item = "tent3", label = "Large Tent", model = "ba_prop_battle_tent_02", isFrozen = true},
    {item = "hobostove", label = "Hobo Stove", model = "prop_hobo_stove_01", isFrozen = true},
    {item = "campfire", label = "Campfire", model = "prop_beach_fire", isFrozen = true},
    {item = "hobomattress", label = "Hobo Mattress", model = "prop_rub_matress_01", isFrozen = true},
    {item = "hoboshelter", label = "Hobo Shelter", model = "prop_homeles_shelter_01", isFrozen = true},
    {item = "sleepingbag", label = "Sleeping Bag", model = "prop_skid_sleepbag_1", isFrozen = true},
    {item = "canopy1", label = "Canopy (Green)", model = "prop_gazebo_01", isFrozen = true},
    {item = "canopy2", label = "Canopy (Blue)", model = "prop_gazebo_02", isFrozen = true},
    {item = "canopy3", label = "Canopy (White)", model = "prop_gazebo_03", isFrozen = true},
    {item = "cot", label = "Cot", model = "gr_prop_gr_campbed_01", isFrozen = true},

    -- Triathlon props
    {item = "tristarttable", label = "Triathlon Start Table", model = "prop_tri_table_01", isFrozen = true},
    {item = "tristartbanner", label = "Triathlon Start Banner", model = "prop_tri_start_banner", isFrozen = true},
    {item = "trifinishbanner", label = "Triathlon Finish Banner", model = "prop_tri_finish_banner", isFrozen = true},

    -- Table props
    {item = "plastictable", label = "Plastic Table", model = "prop_ven_market_table1", isFrozen = true},
    {item = "plastictable2", label = "Plastic Table", model = "prop_table_03", isFrozen = true},
    {item = "woodtable", label = "Small Wood Table", model = "prop_rub_table_01", isFrozen = true},
    {item = "woodtable2", label = "Wood Table", model = "prop_rub_table_02", isFrozen = true},

    -- Beach props
    {item = "beachtowel", label = "Beach Towel", model = "prop_cs_beachtowel_01", isFrozen = true},
    {item = "beachumbrella", label = "Beach Umbrella", model = "prop_parasol_04b", isFrozen = true},
    {item = "beachumbrella2", label = "Beach Umbrella", model = "prop_beach_parasol_02", isFrozen = true},
    {item = "beachumbrella3", label = "Beach Umbrella", model = "prop_beach_parasol_06", isFrozen = true},
    {item = "beachumbrella4", label = "Beach Umbrella", model = "prop_beach_parasol_10", isFrozen = true},
    {item = "beachball", label = "Beach Ball", model = "prop_beachball_02", isFrozen = false},

    -- Ramp props
    {item = "ramp1", label = "Wood Ramp (Gradual)", model = "prop_mp_ramp_01", isFrozen = true},
    {item = "ramp2", label = "Wood Ramp (Moderate)", model = "prop_mp_ramp_02", isFrozen = true},
    {item = "ramp3", label = "Wood Ramp (Steep)", model = "prop_mp_ramp_03", isFrozen = true},
    {item = "ramp4", label = "Metal Ramp (Large)", model = "xs_prop_arena_pipe_ramp_01a", isFrozen = true},
    {item = "ramp5", label = "Metal Trailer Ramp", model = "xs_prop_x18_flatbed_ramp", isFrozen = true},
    {item = "skateramp", label = "Skate Ramp", model = "prop_skate_flatramp", isFrozen = true},
    {item = "stuntramp1", label = "Stunt Ramp S", model = "stt_prop_ramp_adj_flip_s", isFrozen = true},
    {item = "stuntramp2", label = "Stunt Ramp M", model = "stt_prop_ramp_adj_flip_m", isFrozen = true},
    {item = "stuntramp3", label = "Stunt Ramp L", model = "stt_prop_ramp_jump_l", isFrozen = true},
    {item = "stuntramp4", label = "Stunt Ramp XL", model = "stt_prop_ramp_jump_xl", isFrozen = true},
    {item = "stuntramp5", label = "Stunt Ramp XXL", model = "stt_prop_ramp_jump_xxl", isFrozen = true},
    {item = "stuntloop1", label = "Stunt Half Loop", model = "stt_prop_ramp_adj_hloop", isFrozen = true},
    {item = "stuntloop2", label = "Stunt Loop", model = "stt_prop_ramp_adj_loop", isFrozen = true},
    {item = "stuntloop3", label = "Stunt Spiral", model = "stt_prop_ramp_spiral_s", isFrozen = true},

    -- EMS/Hospital props
    {item = "medbag", label = "Medical Bag", model = "xm_prop_x17_bag_med_01a", isFrozen = true},
    {item = "examlight", label = "Exam Light", model = "v_med_examlight", isFrozen = true},
    {item = "hazardbin", label = "Hazard Bin", model = "v_med_medwastebin", isFrozen = true},
    {item = "microscope", label = "Microscope", model = "v_med_microscope", isFrozen = true},
    {item = "oscillator", label = "Oscillator", model = "v_med_oscillator3", isFrozen = true},
    {item = "medmachine", label = "Medical Machine", model = "v_med_oscillator4", isFrozen = true},
    {item = "bodybag", label = "Body Bag", model = "xm_prop_body_bag", isFrozen = true},

    -- Chairs
    {item = "camp_chair_green", label = "Camp Chair (Green)", model = "prop_skid_chair_01", isFrozen = true, customTargetOptions = chairCustomTargetOptions},
    {item = "camp_chair_blue", label = "Camp Chair (Blue)", model = "prop_skid_chair_02", isFrozen = true, customTargetOptions = chairCustomTargetOptions},
    {item = "camp_chair_plaid", label = "Camp Chair (Plaid)", model = "prop_skid_chair_03", isFrozen = true, customTargetOptions = chairCustomTargetOptions},
    {item = "plastic_chair", label = "Plastic Chair", model = "prop_chair_08", isFrozen = true, customTargetOptions = chairCustomTargetOptions},
    {item = "folding_chair", label = "Folding Chair", model = "xm3_prop_xm3_folding_chair_01a", isFrozen = true, customTargetOptions = chairCustomTargetOptions},

    -- Cargo props
    {item = "cargobox1", label = "Large cardboardbox pallet", model = "prop_mb_cargo_03a", isFrozen = false},
    {item = "cargobox2", label = "Large mixed pallet", model = "prop_mb_cargo_02a", isFrozen = false},
    {item = "cargobox3", label = "Tall wrapped pallet", model = "hei_prop_carrier_cargo_04b", isFrozen = false},
    {item = "cargobox4", label = "Cardboardboxes pallet", model = "prop_boxpile_02c", isFrozen = false},
    {item = "cargobox5", label = "Sprunk boxes pallet", model = "prop_boxpile_03a", isFrozen = false},
    {item = "cargobox6", label = "Cardboardboxes wrapped", model = "prop_boxpile_04a", isFrozen = false},
    {item = "cargobox7", label = "Cardboardboxes fragile", model = "prop_boxpile_06a", isFrozen = false},
    {item = "cargobox8", label = "Cardboardboxes + keg", model = "prop_boxpile_09a", isFrozen = false},
    {item = "pallet1", label = "Empty pallet", model = "prop_pallet_01a", isFrozen = false},
    {item = "pallet2", label = "Fertilizer pallet", model = "bkr_prop_fertiliser_pallet_01a", isFrozen = false},
    {item = "pallet3", label = "Weed bricks pallet", model = "hei_prop_heist_weed_pallet", isFrozen = false},
    {item = "pallet4", label = "Barrell pallet", model = "xm3_prop_xm3_pallet_ch_01a", isFrozen = false},
    {item = "pallet5", label = "Slotmachine pallet", model = "sf_prop_sf_slot_pallet_01a", isFrozen = false},
    {item = "crate1", label = "Gopostal crate", model = "prop_box_wood03a", isFrozen = false},
    {item = "crate2", label = "Wood crate", model = "prop_box_wood04a", isFrozen = false},
    {item = "crate3", label = "Cluckinbell crate", model = "vw_prop_vw_boxwood_01a", isFrozen = false},
    {item = "crate4", label = "Water crate", model = "prop_watercrate_01", isFrozen = false},
    {item = "crate5", label = "Animal cage", model = "v_med_apecrate", isFrozen = false},

    -- Xmas props
    {item = "snowman1", label = "Snowman (Red)", model = "xm3_prop_xm3_snowman_01a", isFrozen = true},
    {item = "snowman2", label = "Snowman (Blue)", model = "xm3_prop_xm3_snowman_01b", isFrozen = true},
    {item = "snowman3", label = "Snowman (Green)", model = "xm3_prop_xm3_snowman_01c", isFrozen = true},
    {item = "snowman4", label = "Snowman", model = "prop_prlg_snowpile", isFrozen = true},
    {item = "xmastree1", label = "Giant Xmas Tree", model = "prop_xmas_ext", isFrozen = true},
    {item = "xmastree2", label = "Xmas Tree", model = "prop_xmas_tree_int", isFrozen = true},
    {item = "candycane", label = "Candy Cane", model = "w_me_candy_xm3", isFrozen = true},
    {item = "xmaspresent", label = "Xmas Present", model = "xm3_prop_xm3_present_01a", isFrozen = true},

    -- Misc props
    {item = "greenscreen", label = "Green Screen", model = "prop_ld_greenscreen_01", isFrozen = true},
    {item = "ropebarrier", label = "Rope Barrier", model = "vw_prop_vw_barrier_rope_01a", isFrozen = false},
    {item = "largesoccerball", label = "Large Soccer Ball", model = "stt_prop_stunt_soccer_ball", isFrozen = false},
    {item = "soccerball", label = "Soccer Ball", model = "p_ld_soc_ball_01", isFrozen = false},
    {item = "stepladder", label = "Step Ladder", model = "v_med_cor_stepladder", isFrozen = true},
    {item = "sexdoll", label = "Sex Doll", model = "prop_defilied_ragdoll_01", isFrozen = true},

    -- Pushable items
    {item = "shoppingcart1", label = "Shopping Cart (Empty)", model = "prop_rub_trolley01a", isFrozen = false, customTargetOptions = pushAndSitTargetOptions},
    {item = "shoppingcart2", label = "Shopping Cart (Full)", model = "prop_skid_trolley_2", isFrozen = false, customTargetOptions = pushTargetOptions},
    {item = "shoppingcart3", label = "Shopping Cart (Empty)", model = "prop_rub_trolley02a", isFrozen = false, customTargetOptions = pushAndSitTargetOptions},
    {item = "shoppingcart4", label = "Shopping Cart (Full)", model = "prop_skid_trolley_1", isFrozen = false, customTargetOptions = pushTargetOptions},
    {item = "wheelbarrow", label = "Wheelbarrow", model = "prop_wheelbarrow01a", isFrozen = false,
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
    {item = "warehousetrolly1", label = "Warehouse Trolly (Empty)", model = "hei_prop_hei_warehousetrolly_02", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushAndSitTargetOptions, {
                offset = {x =  -0.4, y = -1.5, z = -0.9},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }, {
                offset = {x = -0.15, y = 0.15, z = 1.25},
                rotation = {x = 0.0, y = 10.0, z = 175.0},
                animationDict = "anim@amb@business@bgen@bgen_no_work@",
                animationName = "sit_phone_phoneputdown_idle_nowork",
            }
        )
    },
    {item = "warehousetrolly2", label = "Warehouse Trolly (Full)", model = "prop_flattruck_01d", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.5, z = -0.9},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "roomtrolly", label = "Room Trolly", model = "ch_prop_ch_room_trolly_01a", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.8},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "janitorcart1", label = "Janitor Cart", model = "prop_cleaning_trolly", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.3, y = -1.6, z = -0.9},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "janitorcart2", label = "Janitor Cart", model = "ch_prop_ch_trolly_01a", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.3, y = -1.75, z = -0.3},
                rotation = {x = 0.0, y = 0.0, z = 270.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "mopbucket", label = "Mop Bucket", model = "prop_tool_mopbucket", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.3, y = -1.9, z = -0.8},
                rotation = {x = 0.0, y = 0.0, z = 270.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "metalcart", label = "Metal Cart", model = "prop_gold_trolly", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.35},
                rotation = {x = 0.0, y = 0.0, z = 270.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "teacart", label = "Tea Cart", model = "prop_tea_trolly", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.4},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "drinkcart", label = "Drink Cart", model = "h4_int_04_drink_cart", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.4},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "handtruck1", label = "Hand Truck", model = "prop_sacktruck_02a", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.4, z = -0.8},
                rotation = {x = -35.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "handtruck2", label = "Hand Truck (Boxes)", model = "prop_sacktruck_02b", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.4, z = -0.75},
                rotation = {x = -35.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "trashbin", label = "Trash Bin", model = "prop_cs_bin_01_skinned", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushAndSitTargetOptions, {
                offset = {x =  -0.4, y = -1.62, z = -0.8},
                rotation = {x = -15.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }, {
                offset = {x = 0.02, y = 0.15, z = 1.25},
                rotation = {x = 0.0, y = 0.0, z = 175.0},
                animationDict = "anim@model_kylie_insta",
                animationName = "kylie_insta_clip",
            }
        )
    },
    {item = "lawnmower", label = "Lawn Mower", model = "prop_lawnmower_01", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.43, y = -1.6, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "toolchest", label = "Tool Chest", model = "prop_toolchest_03", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.95, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "carjack", label = "Car Jack", model = "prop_carjack", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.75, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "hospitalbedtable", label = "Hospital Bedside Table", model = "v_med_bedtable", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.7, z = -0.35},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "medtable", label = "Medical Table", model = "v_med_trolley2", isFrozen = false,
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.75, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },

    -- ADDON ITEMS

    -- Yogamats
    -- Uncomment this line if you are using wp-yogamats
    -- {item = "yogamat_blue", label = "Yoga mat (Blue)", model = "prop_yoga_mat_01", isFrozen = true, customTargetOptions = yogaCustomTargetOptions},
    -- {item = "yogamat_black", label = "Yoga mat (Black)", model = "prop_yoga_mat_02", isFrozen = true, customTargetOptions = yogaCustomTargetOptions},
    -- {item = "yogamat_red", label = "Yoga mat (Red)", model = "prop_yoga_mat_03", isFrozen = true, customTargetOptions = yogaCustomTargetOptions},

    -- Printers
    -- Uncomment this line if you are using wp-printer
    -- {item = "printer", label = "Printer", model = "prop_printer_01", isFrozen = true, customTargetOptions = printerCustomTargetOptions},
    -- {item = "printer2", label = "Printer", model = "prop_printer_02", isFrozen = true, customTargetOptions = printerCustomTargetOptions},
    -- {item = "printer3", label = "Printer", model = "v_res_printer", isFrozen = true, customTargetOptions = printerCustomTargetOptions},
    -- {item = "printer4", label = "Printer", model = "v_ret_gc_print", isFrozen = true, customTargetOptions = printerCustomTargetOptions},
    -- {item = "photocopier", label = "Photocopier", model = "v_med_cor_photocopy", isFrozen = true, customTargetOptions = printerCustomTargetOptions},
    
    -- Fireworks
    -- Uncomment this line if you are using wp-fireworks
    -- {item = "finalefirework1",   label = "Finale Firework (White)", model = "bzzz_prop_fireworks_a", isFrozen = true, customTargetOptions = fireworkCustomTargetOptions},
    -- {item = "finalefirework2",   label = "Finale Firework (Colored)", model = "bzzz_prop_fireworks_a", isFrozen = true, customTargetOptions = fireworkCustomTargetOptions},
    -- {item = "finalefirework3",   label = "Finale Firework (USA)", model = "bzzz_prop_fireworks_a", isFrozen = true, customTargetOptions = fireworkCustomTargetOptions},
    -- {item = "fountainfirework1", label = "Fountain Firework (White)", model = "ind_prop_firework_03", isFrozen = true, customTargetOptions = fireworkCustomTargetOptions},
    -- {item = "fountainfirework2", label = "Fountain Firework (Colored)", model = "ind_prop_firework_03", isFrozen = true, customTargetOptions = fireworkCustomTargetOptions},
    -- {item = "fountainfirework3", label = "Fountain Firework (USA)", model = "ind_prop_firework_03", isFrozen = true, customTargetOptions = fireworkCustomTargetOptions},
    -- {item = "missilefirework1",  label = "Missile Firework (White)", model = "ind_prop_firework_04", isFrozen = true, customTargetOptions = fireworkCustomTargetOptions},
    -- {item = "missilefirework2",  label = "Missile Firework (Colored)", model = "ind_prop_firework_04", isFrozen = true, customTargetOptions = fireworkCustomTargetOptions},
    -- {item = "missilefirework3",  label = "Missile Firework (USA)", model = "ind_prop_firework_04", isFrozen = true, customTargetOptions = fireworkCustomTargetOptions},
    -- {item = "strobefirework",    label = "Strobe Firework", model = "bzzz_prop_fireworks_b", isFrozen = true, customTargetOptions = fireworkCustomTargetOptions},
    
    -- Traffic lights
    -- Uncomment this line if you are using wp-trafficlights
    -- {item = "trafficlight", label= "Traffic light", model = "prop_traffic_03a", isFrozen = true, customTargetOptions = trafficLightCustomTargetOptions, customPickupEvent = trafficLightCustomPickupEvent},

    -- ADD YOUR CUSTOM PROPS HERE
}
