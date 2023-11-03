local isDoingYoga = false
local animationDict = "missfam5_yoga"
local yogaPoses = {
    "start_pose",
    "start_to_a1",
    "a1_pose",
    "a1_to_a2",
    "a2_pose",
    "a2_to_a3",
    "a3_pose",
    "a3_to_b4",
    "b4_pose",
    "b4_to_start",
    "start_to_c1",
    "c1_pose",
    "c1_to_c2",
    "c2_pose",
    "c2_to_c3",
    "c3_pose",
    "c3_to_c4",
    "c4_pose",
    "c4_to_c5",
    "c5_pose",
    "c5_to_c6",
    "c6_pose",
    "c6_to_c7",
    "c7_pose",
    "c7_to_c8",
    "c8_pose",
    "c8_to_start",
    "f_yogapose_a",
    "f_yogapose_b",
    "f_yogapose_c",
}

-- Thread to control actively doing yoga on the mat and the different poses
local function startYogaMatInteraction(yogaMatEntity)
    local ped = PlayerPedId()
    ClearPedTasks(ped)

    isDoingYoga = true

    -- Put player in the center of the mat and facing the correct direction
    local yogaMatCoords = GetEntityCoords(yogaMatEntity)
    local yogaMatHeading = GetEntityHeading(yogaMatEntity)
    SetEntityCoords(ped, yogaMatCoords)
    SetEntityHeading(ped, yogaMatHeading-90)

    LoadAnimDict(animationDict)

    -- Put the player in the starting yoga pose
    TaskPlayAnim(ped, animationDict, yogaPoses[1] , 8.0, -8.0, -1, 2, 0, false, false, false)

    -- Start a thread that handles listening for keypresses while the player is actively using the yoga mat 
    -- Handles key presses for LEFT, RIGHT, UP arrows for cycling the emotes,
    -- BACKSPACE or walking away from the yoga mat will cancel out of the thread
    CreateThread(function()
        local index = 2 -- Start at index 2 since player is already in the first pose
        while isDoingYoga do
            if IsControlJustPressed(0, 194) or (#(GetEntityCoords(ped) - yogaMatCoords) > 5) then -- BACKSPACE or walk away to cancel
                isDoingYoga = false
                ClearPedTasks(ped)
            elseif IsControlJustPressed(0, 188) then -- UP arrow - begin yoga loop
                ClearPedTasks(ped)
                TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_YOGA', 0, true)
            elseif IsControlJustPressed(0, 189) then -- LEFT arrow - cycle poses
                if index <= 1 then 
                    index = #yogaPoses
                else
                    index = index - 1
                end
                TaskPlayAnim(ped, animationDict, yogaPoses[index] , 8.0, -8.0, -1, 2, 0, false, false, false)
            elseif IsControlJustPressed(0, 190) then -- RIGHT arrow - cycle poses
                if index >= #yogaPoses then
                    index = 1
                else
                    index = index + 1
                end
                TaskPlayAnim(ped, animationDict, yogaPoses[index] , 8.0, -8.0, -1, 2, 0, false, false, false)
            end
            Wait(1)
        end
    end)

    if Config.YogaMats.ShouldReduceStress or Config.YogaMats.ShouldIncreaseHealth then
        -- Thread handles periodically applying the stress + health buffs
        CreateThread(function()
            while isDoingYoga do
                Wait(Config.YogaMats.BuffInterval)

                if Config.YogaMats.ShouldReduceStress then
                    SetPlayerStressMetaData(-2.0)
                end

                if Config.YogaMats.ShouldIncreaseHealth then
                    SetEntityHealth(ped, GetEntityHealth(ped) + 1)
                end
            end
        end)
    end
end

-- Start doing yoga
RegisterNetEvent('wp-placeables:client:useYogaMat', function(data)
    local yogaMatEntity = data.entity

    Notify('Left/Right arrow keys to cycle poses. Up arrow to loop. Backspace to exit.', 'primary', 7500)

    startYogaMatInteraction(yogaMatEntity)
end)
