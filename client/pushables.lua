local isAttached = false
local isSittingOnObject = false
local pushableObject = nil

-- Detaches the object from the player, stops the animation, and resets the variables
local function ReleasePushableObject()
    DetachEntity(pushableObject, false, true)
    SetEntityCollision(pushableObject, true, true)
    ClearPedTasksImmediately(PlayerPedId())

    -- Reset variables
    isAttached = false
    isSittingOnObject = false
    pushableObject = nil
end

-- Runs a thread while player is attached to the pushable object, disables some keys and listens for E keypress to release the object
-- Also checks that player is still in the animation, if not then puts them back into the animation
local function PushableObjectAttachedThread(animDict, anim)
    CreateThread(function()
        while isAttached do
            -- Disables attacking controls
            DisableControlAction(0, 24, true) -- disable attack
            DisableControlAction(0, 25, true) -- disable aim
            DisableControlAction(0, 47, true) -- disable weapon
            DisableControlAction(0, 58, true) -- disable weapon
            DisableControlAction(0, 263, true) -- disable melee
            DisableControlAction(0, 264, true) -- disable melee
            DisableControlAction(0, 257, true) -- disable melee
            DisableControlAction(0, 140, true) -- disable melee
            DisableControlAction(0, 141, true) -- disable melee
            DisableControlAction(0,142, true) -- disable melee
            DisableControlAction(0, 143, true) -- disable melee

            -- Check to see if animation is still playing, if not then put the player back in the animation
            local playerPed = PlayerPedId()
            if not IsEntityPlayingAnim(playerPed, animDict, anim, 3) and not IsPedRagdoll(playerPed) then
                local animFlag = isSittingOnObject and 5 or 51
                ClearPedTasks(playerPed)
                LoadAnimDict(animDict)
                TaskPlayAnim(playerPed, animDict, anim, 3.0, 3.0, -1, animFlag, 0, 0, 0, 0)
            end

            -- Pressed E
            if IsControlJustPressed(0, 38) then
                ReleasePushableObject()
            end

            Wait(5) -- Needs to be a small number so that player doesnt need to spam press E to get it to take  
        end
    end)
end

-- Attaches the object to the player and plays a pushing animation
local function PushObject(data)
    local PlayerPed = PlayerPedId()

    pushableObject =  data.entity

    if pushableObject then
        local netId = NetworkGetNetworkIdFromEntity(pushableObject)
        RequestNetworkControlOfObject(netId, pushableObject)

        LoadAnimDict(data.animationPushOptions.animationDict)
        TaskPlayAnim(PlayerPed, data.animationPushOptions.animationDict, data.animationPushOptions.animationName, 8.0, 8.0, -1, 51, 0, 0, 0, 0)

        local offset = data.animationPushOptions.offset
        local rotation = data.animationPushOptions.rotation

        SetTimeout(150, function()
            isAttached = true
            SetEntityCollision(pushableObject, false, false)
            AttachEntityToEntity(
                pushableObject,
                PlayerPed,
                GetPedBoneIndex(PlayerPed, 28422),
                offset.x,
                offset.y,
                offset.z,
                rotation.x,
                rotation.y,
                rotation.z,
                false, -- p9
                false, -- usesoftpinner
                true, -- collision
                false, -- isPed
                2, -- rotationorder
                true -- fixrot
            )

            PushableObjectAttachedThread(data.animationPushOptions.animationDict, data.animationPushOptions.animationName)
        end)
    end
end

-- Attaches player to object and plays the sitting animation
local function SitOnObject(data)
    local PlayerPed = PlayerPedId()

    pushableObject = data.entity

    if pushableObject ~= nil then
        LoadAnimDict(data.animationSitOptions.animationDict)
        TaskPlayAnim(PlayerPed, data.animationSitOptions.animationDict, data.animationSitOptions.animationName, 8.0, 8.0, -1, 5, 0, 0, 0, 0)

        local offset = data.animationSitOptions.offset
        local rotation = data.animationSitOptions.rotation

        SetTimeout(150, function()
            isAttached = true
            isSittingOnObject = true
            AttachEntityToEntity(
                PlayerPed,
                pushableObject,
                GetPedBoneIndex(PlayerPed, 11816),
                offset.x,
                offset.y,
                offset.z,
                rotation.x,
                rotation.y,
                rotation.z,
                false, -- p9
                false, -- usesoftpinner
                false, -- collision -- if this is true, then the peds body will collide with things as you push it around
                true, -- isPed
                2, -- rotationorder
                true -- fixrot
            )

            PushableObjectAttachedThread(data.animationSitOptions.animationDict, data.animationSitOptions.animationName)
        end)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if pushableObject then
            ReleasePushableObject()
            DeleteObject(pushableObject)
            ClearPedTasksImmediately(PlayerPedId())
        end
    end
end)

RegisterNetEvent('wp-placeables:client:pushObject', function(data)
    PushObject(data)
end)

RegisterNetEvent('wp-placeables:client:sitOnObject', function(data)
    SitOnObject(data)
end)

local function IsPlayerSittingOnPlaceableProp()
    return isSittingOnObject
end
exports('IsPlayerSittingOnPlaceableProp', IsPlayerSittingOnPlaceableProp)
