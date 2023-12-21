-- IsDuplicityVersion - is used to determine if the function is called by the server or the client (true == from server)

--------------------- SHARED FUNCTIONS ---------------------
Core = nil
---@return table Core The core object of the framework
function GetCoreObject()
    if not Core then
        if Config.Framework == 'esx' then
            Core = exports['es_extended']:getSharedObject()
        elseif Config.Framework == 'qb' then
            Core = exports['qb-core']:GetCoreObject()
        end
    end
    return Core
end

Core = Config.Framework ~= 'none' and GetCoreObject() or nil

---@param text string The text to show in the notification
---@param notificationType string The type of notification to show ex: 'success', 'error', 'info'
---@param src - number|nil The source of the player - only required when called from server side
function Notify(text, notificationType, src)
    if IsDuplicityVersion() then
        if Config.Notify == 'esx' then
            TriggerClientEvent("esx:showNotification", src, text)
        elseif Config.Notify == 'qb' then
            TriggerClientEvent('QBCore:Notify', src, text, notificationType)
        elseif Config.Notify == 'ox' then
            TriggerClientEvent("ox_lib:notify", src, {
                description = text,
                type = notificationType
            })
        end
    else
        if Config.Notify == 'esx' then
            Core.ShowNotification(text)
        elseif Config.Notify == 'qb' then
            Core.Functions.Notify(text, notificationType)
        elseif Config.Notify == 'ox' then
            lib.notify({
                description = text,
                type = notificationType
            })
        end
    end
end

---@param source number|nil The source of the player
---@return table PlayerData The player data of the player
function GetPlayerData(source)
    local Core = GetCoreObject()
    if IsDuplicityVersion() then
        if Config.Framework == 'esx' then
            return Core.GetPlayerFromId(source)
        elseif Config.Framework == 'qb' then
            return Core.Functions.GetPlayer(source)
        end
    else
        if Config.Framework == 'esx' then
            return Core.GetPlayerData()
        elseif Config.Framework == 'qb' then
            return Core.Functions.GetPlayerData()
        end
    end
end

--------------------- CLIENT FUNCTIONS ---------------------

---@param name string The name of the event to trigger
---@param cb function The callback to call when the event is triggered
---@param ... any The arguments to pass to the event
---@return any The return value of the event
function TriggerCallback(name, cb, ...)
    if IsDuplicityVersion() then return end
    if Config.Framework == 'esx' then
        return Core.TriggerServerCallback(name, cb, ...)
    elseif Config.Framework == 'qb' then
        return Core.Functions.TriggerCallback(name, cb, ...)
    end
end

-- Triggers a progressbar on the client
-- This uses the same method signature as QBCore Progressbar
---@param name string The name of the progressbar
---@param label string The label to show on the progressbar
---@param duration number The duration of the progressbar
---@param useWhileDead boolean Whether or not the progressbar should be used while dead
---@param canCancel boolean Whether or not the progressbar can be cancelled
---@param disableControls table Contains the controls to disable while the progressbar is active (disableMovement, disableCarMovement, disableMouse, disableCombat)
---@param animation table Contains the animation to play while the progressbar is active (animDict, anim, flags)
---@param prop table Contains the prop to show while the progressbar is active (model, bone, coords, rotation)
---@param propTwo table Contains the prop to show while the progressbar is active (model, bone, coords, rotation)
---@param onFinish function The callback function to call when the progressbar finishes
---@param onCancel function The callback function to call when the progressbar is cancelled
function Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    if IsDuplicityVersion() then return end
    if Config.ProgessBar == 'none' then
        onFinish()
    elseif Config.ProgessBar == 'qb' then
        return Core.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    elseif Config.ProgessBar == 'ox' then
        local props = {}
        if prop then
            props[1] = {
                model = prop.model,
                bone = prop.bone,
                coords = prop.coords,
                rotation = prop.rotation,
            }
        end
        if propTwo then
            props[2] = {
                model = propTwo.model,
                bone = propTwo.bone,
                coords = propTwo.coords,
                rotation = propTwo.rotation,
            }
        end

        if lib.progressBar({
            name = name,
            label = label,
            duration = duration,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            disable = {
                move = disableControls.disableMovement,
                car = disableControls.disableCarMovement,
                mouse = disableControls.disableMouse,
                combat = disableControls.disableCombat,
            },
            anim = {
                dict = animation.animDict,
                clip = animation.anim,
                flag = animation.flags,
            },
            prop = props,
        }) then
            onFinish()
        else
            onCancel()
        end
    end
end

-- Takes a prop model and the targetOptions and adds it to the target script so that this prop model is targetable
---@param model string The name of the prop model to target
---@param targetOptions table The options to pass to the target script 
---        ex: targetOptions = { distance = num, options: { offset = { x = 0.0, y = 0.0, z = 0.0 }, rotation = { x = 0.0, y = 0.0, z = 0.0 } , animationDict = "", animationName = "" } }
function AddTargetModel(modelName, targetOptions)
    if IsDuplicityVersion() then return end
    if Config.Target == 'qb' then
        exports['qb-target']:AddTargetModel(modelName, targetOptions)
    elseif Config.Target == 'ox' then
        -- ox target expects each option to have a distance on it,
        -- Append the distance value to each option
        for _, option in pairs(targetOptions.options) do
            option.distance = targetOptions.distance
        end
        exports.ox_target:addModel(modelName, targetOptions.options)
    else
        print('Missing target implementation for wp-placeables')
    end
end

-- Creates a log entry when an item is placed or picked up
---@param itemName string The name of the item that was placed or picked up
---@param isItemPlaced boolean True if the item was placed, false if the item was picked up
function CreateLog(itemName, isItemPlaced)
    if IsDuplicityVersion() or Config.Log == 'none' then return end

    local playerId = PlayerId()
    local playerName = GetPlayerName(playerId)
    local PlayerData = GetPlayerData()
    local color = isItemPlaced and "red" or "green"
    local action = isItemPlaced and "Placed" or "Picked up"
    local logMessage = "**" .. playerName .. "** (".. PlayerData.charinfo.firstname.." "..PlayerData.charinfo.lastname..") | CitizenId: "..PlayerData.citizenid.."\n Item Name: "..itemName
    
    if Config.Log == 'qb' then
        -- Be sure to add the 'itemplacement' entry to the qb-log config
        TriggerServerEvent("qb-log:server:CreateLog", "itemplacement", "Item "..action.." By:", color, logMessage)
    else
        print('Missing log implementation for wp-placeables!')
    end
end

--------------------- SERVER FUNCTIONS ---------------------

function CreateCallback(...)
    if not IsDuplicityVersion() then return end
    if Config.Framework == 'esx' then
        return Core.RegisterServerCallback(...)
    elseif Config.Framework == 'qb' then
        return Core.Functions.CreateCallback(...)
    end
end

function CreateUseableItem(...)
    if not IsDuplicityVersion() then return end
    if Config.Framework == 'esx' then
        return Core.RegisterUsableItem(...)
    elseif Config.Framework == 'qb' then
        return Core.Functions.CreateUseableItem(...)
    end
end

-- Adds item to the players inventory
---@param source number The source of the player
---@param itemName string The name of the item to add
---@param amount number The amount of the item to add
function AddItem(source, itemName, amount)
    if not IsDuplicityVersion() then return end
    if Config.Inventory == 'esx' then
        local xPlayer = Core.GetPlayerFromId(source)
        return xPlayer.addInventoryItem(itemName, amount)
    elseif Config.Inventory == 'qb' then
        local Player = Core.Functions.GetPlayer(source)
        TriggerClientEvent('inventory:client:ItemBox', source, Core.Shared.Items[itemName], "add")
        return Player.Functions.AddItem(itemName, amount) 
    elseif Config.Inventory == 'ox' then
        exports.ox_inventory:AddItem(source, itemName, amount)
    end
end

-- Removes item from the players inventory
---@param source number The source of the player
---@param itemName string The name of the item to remove
---@param amount number The number of items to remove
function RemoveItem(source, itemName, amount)
    if not IsDuplicityVersion() then return end
    if Config.Inventory == 'esx' then
        local xPlayer = Core.GetPlayerFromId(source)
        return xPlayer.removeInventoryItem(itemName, amount)
    elseif Config.Inventory == 'qb' then
        local Player = Core.Functions.GetPlayer(source)
        TriggerClientEvent('inventory:client:ItemBox', source, Core.Shared.Items[itemName], "remove")
        return Player.Functions.RemoveItem(itemName, amount)
    elseif Config.Inventory == 'ox' then
        exports.ox_inventory:RemoveItem(source, itemName, amount)
    end
end
