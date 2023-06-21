local QBCore = exports['qb-core']:GetCoreObject()

-- Setup all the placeable props as useable items
for _, prop in pairs(Config.PlaceableProps) do
    QBCore.Functions.CreateUseableItem(prop.item, function(source, item)
        TriggerClientEvent("wp-placeables:client:placeItem", source, QBCore.Shared.Items[prop.item])
    end)
end

-- This function is to handle the syncing of deleting world props between all clients
RegisterServerEvent("wp-placeables:server:deleteWorldObject", function(object)
    TriggerClientEvent("wp-placeables:client:deleteWorldObject", -1, object)
end)

RegisterNetEvent("wp-placeables:server:RemoveItem", function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then 
        Player.Functions.RemoveItem(itemName, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "remove")
    end
end)

RegisterNetEvent("wp-placeables:server:AddItem", function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then 
        Player.Functions.AddItem(itemName, 1)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "add")
    end
end)
