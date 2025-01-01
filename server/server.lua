-- Setup all the placeable props as useable items
for _, prop in pairs(Config.PlaceableProps) do
    CreateUseableItem(prop.item, function(source, item)
        TriggerClientEvent("wp-placeables:client:placeItem", source, prop)
    end)
end

-- Checks the config to see if the item is valid
local function containsItem(item)
    for i = 1, #Config.PlaceableProps do
        local v = Config.PlaceableProps[i]
        if v.item == item then
            return true
        end
    end
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

    if not containsItem(itemName) then
        print(string.format("%s - tried to spawn an item that does not exist in the config (%s)", src, itemName))
        return
    end

    AddItem(src, itemName, 1)
end)
