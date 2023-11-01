local isDoingYoga = false
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

-- Functions

-- Thread to control actively doing yoga on the mat and the different poses
function handleYogaPoses(yogaMatEntity)
    local ped = PlayerPedId()
    local tickRate = 10000
    ClearPedTasks(ped)

    isDoingYoga = true
    TriggerEvent('hud:client:ToggleEffectZone', true)

    -- Put ped in center of mat
    local yogamatCoords = GetEntityCoords(yogaMatEntity)
    local yogamatHeading = GetEntityHeading(yogaMatEntity)
    SetEntityCoords(ped, yogamatCoords)
    SetEntityHeading(ped, yogamatHeading-90)

    local animationDict = "missfam5_yoga"
    RequestAnimDict(animationDict)
    while not HasAnimDictLoaded(animationDict) do
        Wait(7)
    end

    -- Starting pose
    TaskPlayAnim(ped, animationDict, yogaPoses[1] , 8.0, -8.0, -1, 2, 0, false, false, false)

    -- Thread handles key presses for left, right, up arrows for cycling the emotes
    CreateThread(function()
        local index = 2
        while isDoingYoga do
            if IsControlJustPressed(0, 194) or (#(GetEntityCoords(ped) - yogamatCoords) > 5) then --backspace or player moved too far away
                -- cancel out of yoga
                isDoingYoga = false
                ClearPedTasks(ped)
                TriggerEvent('hud:client:ToggleEffectZone', false)
            elseif IsControlJustPressed(0, 188) then -- up arrow
                ClearPedTasks(ped)
                TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_YOGA', 0, true)
            elseif IsControlJustPressed(0, 189) then -- left arrow
                if index <= 1 then 
                    index = #yogaPoses
                else
                    index = index - 1
                end
                TaskPlayAnim(ped, animationDict, yogaPoses[index] , 8.0, -8.0, -1, 2, 0, false, false, false)
            elseif IsControlJustPressed(0, 190) then -- right arrow
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

    -- Thread handles periodically applying the stress + health buffs
    CreateThread(function()
        Wait(tickRate)
        while isDoingYoga do
            TriggerServerEvent("QBCore:Server:SetMetaData", "stress", QBCore.Functions.GetPlayerData().metadata["stress"] - 2.0)
            SetEntityHealth(ped, GetEntityHealth(ped) + 1)

            Wait(tickRate)
        end
    end)
end


-- Events


-- Start doing yoga
RegisterNetEvent('yogamat:client:doYoga', function(data)
    local ped = PlayerPedId()
    local yogaMatEntity = data.entity

    QBCore.Functions.Notify('Left/right arrow keys to cycle poses. Up arrow to loop. Backspace to exit.', 'primary', 7500)

    handleYogaPoses(yogaMatEntity)
end)
