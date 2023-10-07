local animationDict = "pickup_object"
local animation = "pickup_low"
local isInPlaceItemMode = false

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
local function RayCastGamePlayCamera(distance, object)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination = {
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}

    local traceFlag = 1 -- 1 means the raycast will only intersect with the world (ignoring other entities like peds, cars, etc)
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

local function createLog(itemName, isItemPlaced)
    local PlayerData = GetPlayerData()
    local player = PlayerId()
    local logMessage = "**" .. GetPlayerName(player) .. "** (".. PlayerData.charinfo.firstname.." "..PlayerData.charinfo.lastname..") | CitizenId: "..PlayerData.citizenid.."\n Item Name: "..itemName
    local color = "red" 
    local action = "Placed" 
    if not isItemPlaced then 
        color = "green"
        action = "Picked Up"
    end
    TriggerServerEvent("qb-log:server:CreateLog", "itemplacement", "Item "..action.." By:", color, logMessage)
end

-- This handles placing the actual item that is network synced
local function placeItem(item, coords, heading, shouldSnapToGround)
    local ped = PlayerPedId()
    local itemName = item.name
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

            -- Use statebag property itemNameOverride if `shouldUseItemNameState` is true for the item (defined in items.lua)
            -- This is used for items that use the same model, but need to grant different items when picked up
            -- This is necessary because we use AddTargetModel to provide the options per model and can only apply one set of options per model
            if item.shouldUseItemNameState then
                Entity(obj).state:set('itemNameOverride', itemName, true)
            end

            createLog(itemName, true) 
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

    CreateThread(function()
        while isInPlaceItemMode do
            -- Use raycast based on where the camera is pointed
            local hit, coords, entity = RayCastGamePlayCamera(Config.ItemPlacementModeRadius, obj)

            -- Move the object to the coords from the raycast
            SetEntityCoords(obj, coords.x, coords.y, coords.z + zOffset)

            -- Display the controls
            Draw2DText('[E] Place\n[Shift+E] Place on ground\n[Scroll Up/Down] Rotate\n[Shift+Scroll Up/Down] Raise/lower', 4, {255, 255, 255}, 0.4, 0.85, 0.85)
            Draw2DText('[Right Click / Backspace] Exit place mode', 4, {255, 255, 255}, 0.4, 0.85, 0.945)


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
    local itemName = itemData.itemName
    local itemModel = itemData.itemModel

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

            -- When picking up the item, check if it has a state.itemNameOverride and use that instead of itemName
            -- This is used for items that share a prop model, but are different items. By using the statebag override name instead,
            -- we make sure the player gets the correct item back when they pick it up.
            if Entity(itemEntity).state.itemNameOverride then
                itemName = Entity(itemEntity).state.itemNameOverride
            end

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

            createLog(itemName, false)
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

    -- A model can only have one set of options, so if the model is defined twice, only the last one will be used
    -- If you want to reuse a model, you can use the shouldUseItemNameState flag on the item which enable it to use the state.itemNameOverride
    AddTargetModel(prop.model, {
        options = targetOptions,
        distance = 1.5
    })
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