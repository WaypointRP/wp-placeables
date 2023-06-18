Config = {}

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

local chairCustomTargetOptions = {
    {
        event = "qb-sit:sit",
        icon = "fas fa-chair",
        label = "Sit down",
    },
}

Config.PlaceableProps = {
    -- Constructions props
    {item = "roadworkbarrier", model = "prop_barrier_work04a"},
    {item = "roadclosedbarrier", model = "xm3_prop_xm3_road_barrier_01a"},
    {item = "constructionbarrier", model = "prop_barrier_work01a"},
    {item = "constructionbarrier2", model = "prop_barrier_work06a"},
    {item = "constructionbarrier3", model = "prop_mp_barrier_02b"},
    {item = "roadconebig", model = "prop_barrier_wat_03a"},
    {item = "roadcone", model = "prop_roadcone01a"},
    {item = "roadpole", model = "prop_roadpole_01a"},
    {item = "worklight", model = "prop_worklight_01a"},
    {item = "worklight2", model = "prop_worklight_04b"},
    {item = "worklight3", model = "prop_worklight_02a"},
    {item = "constructiongenerator", model = "prop_generator_03b"},
    {item = "trafficdevice", model = "prop_trafficdiv_01"},
    {item = "trafficdevice2", model = "prop_trafficdiv_02"},
    {item = "meshfence1", model = "prop_fnc_omesh_01a"},
    {item = "meshfence2", model = "prop_fnc_omesh_02a"},
    {item = "meshfence3", model = "prop_fnc_omesh_03a"},
    {item = "waterbarrel", model = "prop_barrier_wat_04a"},

    -- Camping + Hobo props
    {item = "tent", model = "prop_skid_tent_03"},
    {item = "tent2", model = "prop_skid_tent_01"},
    {item = "tent3", model = "ba_prop_battle_tent_02"},
    {item = "hobostove", model = "prop_hobo_stove_01"},
    {item = "campfire", model = "prop_beach_fire"},
    {item = "hobomattress", model = "prop_rub_matress_01"},
    {item = "hoboshelter", model = "prop_homeles_shelter_01"},
    {item = "sleepingbag", model = "prop_skid_sleepbag_1"},
    {item = "canopy1", model = "prop_gazebo_01"},
    {item = "canopy2", model = "prop_gazebo_02"},
    {item = "canopy3", model = "prop_gazebo_03"},
    {item = "cot", model = "gr_prop_gr_campbed_01"},

    -- Triathlon props
    {item = "tristarttable", model = "prop_tri_table_01"},
    {item = "tristartbanner", model = "prop_tri_start_banner"},
    {item = "trifinishbanner", model = "prop_tri_finish_banner"},

    -- Table props
    {item = "plastictable", model = "prop_ven_market_table1"},
    {item = "plastictable2", model = "prop_table_03"},
    {item = "woodtable", model = "prop_rub_table_01"},
    {item = "woodtable2", model = "prop_rub_table_02"},

    -- Beach props
    {item = "beachtowel", model = "prop_cs_beachtowel_01"},
    {item = "beachumbrella", model = "prop_parasol_04b"},
    {item = "beachumbrella2", model = "prop_beach_parasol_02"},
    {item = "beachumbrella3", model = "prop_beach_parasol_06"},
    {item = "beachumbrella4", model = "prop_beach_parasol_10"},
    {item = "beachball", model = "prop_beachball_02"},

    -- Ramp props
    {item = "ramp1", model = "prop_mp_ramp_01"},
    {item = "ramp2", model = "prop_mp_ramp_02"},
    {item = "ramp3", model = "prop_mp_ramp_03"},
    {item = "ramp4", model = "xs_prop_arena_pipe_ramp_01a"},
    {item = "ramp5", model = "xs_prop_x18_flatbed_ramp"},
    {item = "skateramp", model = "prop_skate_flatramp"},
    {item = "stuntramp1", model = "stt_prop_ramp_adj_flip_s"},
    {item = "stuntramp2", model = "stt_prop_ramp_adj_flip_m"},
    {item = "stuntramp3", model = "stt_prop_ramp_jump_l"},
    {item = "stuntramp4", model = "stt_prop_ramp_jump_xl"},
    {item = "stuntramp5", model = "stt_prop_ramp_jump_xxl"},
    {item = "stuntloop1", model = "stt_prop_ramp_adj_hloop"},
    {item = "stuntloop2", model = "stt_prop_ramp_adj_loop"},
    {item = "stuntloop3", model = "stt_prop_ramp_spiral_s"},

    -- EMS/Hospital props
    {item = "medbag", model = "xm_prop_x17_bag_med_01a"},
    {item = "examlight", model = "v_med_examlight"},
    {item = "hazardbin", model = "v_med_medwastebin"},
    {item = "microscope", model = "v_med_microscope"},
    {item = "oscillator", model = "v_med_oscillator3"},
    {item = "medmachine", model = "v_med_oscillator4"},
    {item = "bodybag", model = "xm_prop_body_bag"},

    -- Misc props
    {item = "greenscreen", model = "prop_ld_greenscreen_01"},
    {item = "ropebarrier", model = "vw_prop_vw_barrier_rope_01a"},
    {item = "largesoccerball", model = "stt_prop_stunt_soccer_ball"},
    {item = "soccerball", model = "p_ld_soc_ball_01"},
    {item = "stepladder", model = "v_med_cor_stepladder"},
    {item = "sexdoll", model = "prop_defilied_ragdoll_01"},

    -- Pushable items
    {item = "shoppingcart1", model = "prop_rub_trolley01a", customTargetOptions = pushAndSitTargetOptions},
    {item = "shoppingcart2", model = "prop_skid_trolley_2", customTargetOptions = pushTargetOptions},
    {item = "shoppingcart3", model = "prop_rub_trolley02a", customTargetOptions = pushAndSitTargetOptions},
    {item = "shoppingcart4", model = "prop_skid_trolley_1", customTargetOptions = pushTargetOptions},
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
    {item = "warehousetrolly1", model = "hei_prop_hei_warehousetrolly_02",
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
    {item = "warehousetrolly2", model = "prop_flattruck_01d",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.5, z = -0.9},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "roomtrolly", model = "ch_prop_ch_room_trolly_01a",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.8},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "janitorcart1", model = "prop_cleaning_trolly",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.3, y = -1.6, z = -0.9},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "janitorcart2", model = "ch_prop_ch_trolly_01a",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.3, y = -1.75, z = -0.3},
                rotation = {x = 0.0, y = 0.0, z = 270.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "mopbucket", model = "prop_tool_mopbucket",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.3, y = -1.9, z = -0.8},
                rotation = {x = 0.0, y = 0.0, z = 270.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "metalcart", model = "prop_gold_trolly",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.35},
                rotation = {x = 0.0, y = 0.0, z = 270.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "teacart", model = "prop_tea_trolly",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.4},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "drinkcart", model = "h4_int_04_drink_cart",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.75, z = -0.4},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "handtruck1", model = "prop_sacktruck_02a",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.4, z = -0.8},
                rotation = {x = -35.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "handtruck2", model = "prop_sacktruck_02b",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.4, y = -1.4, z = -0.75},
                rotation = {x = -35.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "trashbin", model = "prop_cs_bin_01_skinned",
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
    {item = "lawnmower", model = "prop_lawnmower_01",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.43, y = -1.6, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "toolchest", model = "prop_toolchest_03",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.95, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "carjack", model = "prop_carjack",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.75, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "hospitalbedtable", model = "v_med_bedtable",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.7, z = -0.35},
                rotation = {x = 0.0, y = 0.0, z = 180.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },
    {item = "medtable", model = "v_med_trolley2",
        customTargetOptions = setCustomTargetOptions(
            pushTargetOptions, {
                offset = {x =  -0.35, y = -1.75, z = -0.83},
                rotation = {x = 0.0, y = 0.0, z = 90.0},
                animationDict = "missfinale_c2ig_11",
                animationName = "pushcar_offcliff_f",
            }
        )
    },

    -- Chairs
    {item = "camp_chair_green", model = "prop_skid_chair_01", customTargetOptions = chairCustomTargetOptions},
    {item = "camp_chair_blue", model = "prop_skid_chair_02", customTargetOptions = chairCustomTargetOptions},
    {item = "camp_chair_plaid", model = "prop_skid_chair_03", customTargetOptions = chairCustomTargetOptions},
    {item = "plastic_chair", model = "prop_chair_08", customTargetOptions = chairCustomTargetOptions},
    {item = "folding_chair", model = "xm3_prop_xm3_folding_chair_01a", customTargetOptions = chairCustomTargetOptions},
}