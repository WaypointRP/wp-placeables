RegisterNetEvent('wp-placeables:printer:client:UseDocument', function(itemData)
    local documentUrl = itemData.info.url ~= nil and itemData.info.url or false
    SendNUIMessage({
        action = "open",
        url = documentUrl
    })
    SetNuiFocus(true, false)
end)

RegisterNetEvent('wp-placeables:printer:client:UsePrinter', function()
    SendNUIMessage({
        action = "start"
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('SaveDocument', function(data)
    if data.url ~= nil then
        TriggerServerEvent('wp-placeables:printer:server:SaveDocument', data.url)
    end
end)

RegisterNUICallback('CloseDocument', function()
    SetNuiFocus(false, false)
end)
