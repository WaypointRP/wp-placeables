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
