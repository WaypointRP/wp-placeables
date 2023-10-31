-- Setup all the placeable props as useable items
for _, prop in pairs(Config.PlaceableProps) do
    CreateUseableItem(prop.item, function(source, item)
        TriggerClientEvent("wp-placeables:client:placeItem", source, prop)
    end)
end

-- This function is to handle the syncing of deleting world props between all clients
RegisterServerEvent("wp-placeables:server:deleteWorldObject", function(object)
    TriggerClientEvent("wp-placeables:client:deleteWorldObject", -1, object)
end)

RegisterNetEvent("wp-placeables:server:RemoveItem", function(itemName)
    local src = source
    RemoveItem(src, itemName, 1)
end)

RegisterNetEvent("wp-placeables:server:AddItem", function(itemName)
    local src = source
    AddItem(src, itemName, 1)
end)
