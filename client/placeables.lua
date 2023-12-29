local animationDict = "pickup_object"
local animation = "pickup_low"
local isInPlaceItemMode = false

-- Keeps track of the models that have already been set with target options, ensuring we don't create duplicate options for the same model
-- In some frameworks like OX, if you create targetOptions on a model that already has it, it will append the options, whereas
-- in QB it will override and only the last set of options will be used. We just need to add one option to the target model and then
-- the pickup event will use the statebag to determine the correct item to give back to the player
local targetModels = {}

local function LoadPropDict(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Wait(10)
    end
end

-- Gets the direction the camera is looking for the raycast function
local function RotationToDirection(rotation)
	local adjustedRotation = {
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction = {
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

-- Uses a RayCast to get the entity, coords, and whether we "hit" something with the raycast
-- Object passed in, is the current object that we want the raycast to ignore
local function RayCastGamePlayCamera(distance, object, raycastDetectWorldOnly)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination = {
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}

    -- Trace flag 4294967295 means the raycast will intersect with everything (including vehicles)
    -- Trace flag 1 means the raycast will only intersect with the world (ignoring other entities like peds, cars, etc)
    local traceFlag = 4294967295
    if raycastDetectWorldOnly then
        traceFlag = 1
    end

	local a, hit, coords, d, entity = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, traceFlag, object, 0))
	return hit, coords, entity
end

-- Used to Draw the text on the screen
local function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

-- This handles placing the actual item that is network synced
local function placeItem(item, coords, heading, shouldSnapToGround)
    local ped = PlayerPedId()
    local itemName = item.item
    local itemModel = item.model
    local shouldFreezeItem = item.isFrozen

    -- Cancel any active animation
    ClearPedTasks(ped)

    Progressbar("place_item", "Placing "..item.label, 750, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = animationDict,
        anim = animation,
        flags = 0,
    }, nil, nil, function() -- Done
        -- Stop playing the animation
        StopAnimTask(ped, animationDict, animation, 1.0)

        -- Remove the item from the inventory
        TriggerServerEvent("wp-placeables:server:RemoveItem", itemName)

        LoadPropDict(itemModel)

        -- Spawn prop on ground at the provided coords and heading
        local obj = CreateObject(itemModel, GetEntityCoords(ped), true)
        if obj ~= 0 then
            SetEntityRotation(obj, 0.0, 0.0, heading, false, false)
            SetEntityCoords(obj, coords)

            if shouldFreezeItem then
                FreezeEntityPosition(obj, true)
            end

            -- Some items dont go to the ground properly with this, and it actually makes them hover
            if shouldSnapToGround then
                PlaceObjectOnGroundProperly(obj)
            end

            -- Use statebag property itemName to set the itemName on the entity.
            -- This value is used to grant the correct item back to the player when they pick it up.
            -- It also solves the issue of the same model being used for multiple items
            Entity(obj).state:set('itemName', itemName, true)

            CreateLog(itemName, true) 
        end

        SetModelAsNoLongerNeeded(itemModel)
    end, function() -- Cancel
        StopAnimTask(ped, animationDict, animation, 1.0)
        Notify("Canceled..", "error")
	end)
end

-- Starts a thread that puts the player into item placement mode
-- This will spawn a local object that only the player can see and move around to position it
-- Once the player places the object it will delete the local one and then create a new network synced object
local function startItemPlacementMode(item)
    -- This is to prevent entering place mode multiple times if its already active
    if isInPlaceItemMode then
        Notify('Already placing an item', 'error', 5000)
        return
    end

    isInPlaceItemMode = true
    local ped = PlayerPedId()
    local itemModel = item.model

    -- Create a local object for only this client (not synced to network) and make it transparent
    local obj = CreateObject(itemModel, GetEntityCoords(ped), false, false)
    SetEntityAlpha(obj, 150, false)
    SetEntityCollision(obj, false, false)

    local zOffset = 0

    -- This is used to determine if the raycast should only detect the world or if it should detect everything (including vehicles)
    local raycastDetectWorldOnly = true

    CreateThread(function()
        while isInPlaceItemMode do
            -- Use raycast based on where the camera is pointed
            local hit, coords, entity = RayCastGamePlayCamera(Config.ItemPlacementModeRadius, obj, raycastDetectWorldOnly)

            -- Move the object to the coords from the raycast
            SetEntityCoords(obj, coords.x, coords.y, coords.z + zOffset)

            -- Display the controls
            Draw2DText('[E] Place\n[Shift+E] Place on ground\n[Scroll Up/Down] Rotate\n[Shift+Scroll Up/Down] Raise/lower', 4, {255, 255, 255}, 0.4, 0.85, 0.85)
            Draw2DText('[Scroll Click] Change mode\n[Right Click / Backspace] Exit place mode', 4, {255, 255, 255}, 0.4, 0.85, 0.945)

            -- Handle various key presses and actions

            -- Controls for placing item

            -- Pressed Shift + E - Place object on ground
            if IsControlJustReleased(0, 38) and IsControlPressed(0, 21)then
                isInPlaceItemMode = false

                local objHeading = GetEntityHeading(obj)
                local snapToGround = true

                DeleteEntity(obj)
                placeItem(item, vector3(coords.x, coords.y, coords.z + zOffset), objHeading, snapToGround)

            -- Pressed E - Place object at current position
            elseif IsControlJustReleased(0, 38) then
                isInPlaceItemMode = false

                local objHeading = GetEntityHeading(obj)
                local snapToGround = false

                DeleteEntity(obj)
                placeItem(item, vector3(coords.x, coords.y, coords.z + zOffset), objHeading, snapToGround)
            end

            -- Controls for rotating item

            -- Mouse Wheel Up (and Shift not pressed), rotate by +10 degrees
            if IsControlJustReleased(0, 241) and not IsControlPressed(0, 21) then
                local objHeading = GetEntityHeading(obj)
                SetEntityRotation(obj, 0.0, 0.0, objHeading + 10, false, false)
            end

            -- Mouse Wheel Down (and shift not pressed), rotate by -10 degrees
            if IsControlJustReleased(0, 242) and not IsControlPressed(0, 21) then
                local objHeading = GetEntityHeading(obj)
                SetEntityRotation(obj, 0.0, 0.0, objHeading - 10, false, false)
            end

            -- Controls for raising/lowering item

            -- Shift + Mouse Wheel Up, move item up
            if IsControlPressed(0, 21) and IsControlJustReleased(0, 241) then
                zOffset = zOffset + 0.1
                if zOffset > Config.maxZOffset then
                    zOffset = Config.maxZOffset
                end
            end

            -- Shift + Mouse Wheel Down, move item down
            if IsControlPressed(0, 21) and IsControlJustReleased(0, 242) then
                zOffset = zOffset - 0.1
                if zOffset < Config.minZOffset then
                    zOffset = Config.minZOffset
                end
            end

            -- Mouse Wheel Click, change placement mode
            if IsControlJustReleased(0, 348) then
                raycastDetectWorldOnly = not raycastDetectWorldOnly
            end

            -- Right click or Backspace to exit out of placement mode and delete the local object
            if IsControlJustReleased(0, 177) then
                isInPlaceItemMode = false
                DeleteEntity(obj)
            end

            Wait(1)
        end
    end)
end

-- Handles picking up the prop, deleting it from the world and adding it to the players inventory
local function pickUpItem(itemData)
    local ped = PlayerPedId()
    local itemEntity = itemData.entity
    local itemModel = itemData.itemModel

    -- When picking up the item, try to get the itemName from the statebag property first, else fallback to the itemName from the itemData provided by the target script
    -- Using the statebag property ensures we get the correct item name if the prop model is shared by multiple items..
    local itemName = Entity(itemEntity).state.itemName or itemData.itemName

    if itemName then
        -- Cancel any active animation
        ClearPedTasks(ped)

        Progressbar("pickup_item", "Picking up item", 200, false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = animationDict,
            anim = animation,
            flags = 0,
        }, nil, nil, function() -- Done
            -- Stop playing the animation
            StopAnimTask(ped, animationDict, animation, 1.0)

            -- Add the item to the inventory
            TriggerServerEvent("wp-placeables:server:AddItem", itemName)

            -- First request control of networkId and wait until have control of netId before deleting it
            -- Item will not properly delete if the client doesn't have control of the networkId
            local coords = GetEntityCoords(itemEntity)
            local netId = NetworkGetNetworkIdFromEntity(itemEntity)
            RequestNetworkControlOfObject(netId, itemEntity)
            SetEntityAsMissionEntity(itemEntity, true, true)
            DeleteEntity(itemEntity)

            local object = {coords = coords, model = itemModel}
            TriggerServerEvent("wp-placeables:server:deleteWorldObject", object)

            CreateLog(itemName, false)
        end, function() -- Cancel
            StopAnimTask(ped, animationDict, animation, 1.0)
            Notify("Canceled..", "error")
        end)
    end
end

RegisterNetEvent('wp-placeables:client:placeItem', function(item)
    if not IsPedInAnyVehicle(PlayerPedId(), true) then
        startItemPlacementMode(item)
    else
        Notify('You cannot place items while in a vehicle', 'error', 5000)
    end
end)

RegisterNetEvent('wp-placeables:client:pickUpItem', function(data)
    pickUpItem(data)
end)

-- Setup each placeable prop to use QB target
-- Itemname is in the options so we know which item to give back when picked up
for _, prop in pairs(Config.PlaceableProps) do
    local pickUpEvent = "wp-placeables:client:pickUpItem"
    if prop.customPickupEvent then
        pickUpEvent = prop.customPickupEvent
    end
    local targetOptions = {
        {
            event = pickUpEvent,
            icon = "fas fa-hand-holding",
            label = "Pick up",
            itemName = prop.item,
            itemModel = prop.model,
        },
    }

    -- Add custom target options to the target options for this item prop
    if prop.customTargetOptions then
        for _, customOption in pairs(prop.customTargetOptions) do
            -- Stamp the itemName and itemModel onto the data so the custom events have access to this info
            customOption.itemName = prop.item
            customOption.itemModel = prop.model

            targetOptions[#targetOptions + 1] = customOption
        end
    end
    
    -- Make sure we only define the target options once for each model
    -- If you define the same model twice:
    --      In qb-target, it will override the options, and the last one defined is used
    --      In ox_target, it will append the options, resulting in N duplicate options
    if not targetModels[prop.model] then
        AddTargetModel(prop.model, {
            options = targetOptions,
            distance = 1.5  
        })
        targetModels[prop.model] = true
    end
end

-- Delete the world object
-- object = {coords = coords, model = itemModel}
RegisterNetEvent("wp-placeables:client:deleteWorldObject", function(object)
    local entity = GetClosestObjectOfType(object.coords.x, object.coords.y, object.coords.z, 0.1, object.model, false, false, false)
    if DoesEntityExist(entity) then
        SetEntityAsMissionEntity(entity, 1, 1)
        DeleteObject(entity)
        SetEntityAsNoLongerNeeded(entity)
    end
end)

-- Runs a thread to loop through the deleted world objects table and removes the item if it exists
-- This is to handle cases if the item were to have respawned
-- Disabling this for now since we dont need to care if the item respawns
-- There is currently an issue where this was being used for both player placed objects as well as world props
-- If you placed an item, picked it up and placed the same item down again, the cleanup thread would delete it since its at the same coords.
-- If we want to re-enable this, we need to find a way to only use this cleanup thread on world spawned props
-- AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
--     QBCore.Functions.TriggerCallback('wp-placeables:server:GetDeletedWorldObjects', function(deletedObjects)
--         objects = deletedObjects
--     end)
-- end)
-- CreateThread(function()
--     while true do
--         for k = 1, #objects, 1 do
--             v = objects[k]
--             local entity = GetClosestObjectOfType(v.coords.x, v.coords.y, v.coords.z, 0.1, v.model, false, false, false)
--             if DoesEntityExist(entity) then
--                 SetEntityAsMissionEntity(entity, 1, 1)
--                 DeleteObject(entity)
--                 SetEntityAsNoLongerNeeded(entity)
--             end
--         end
--         Wait(10000)
--     end
-- end)