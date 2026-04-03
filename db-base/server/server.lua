-- db-base / server/server.lua
-- Platz für Server-Logik. Aktuell nur Grundgerüst.

local QBCore = exports['qb-core'] and exports['qb-core']:GetCoreObject()

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res then return end
    print('^2[db-base]^7 Server gestartet.')
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res then return end
    print('^1[db-base]^7 Server gestoppt.')
end)

-- Hairstyle Item-Logic: Hook in tgiann-inventory/server/editable.lua -> useItemEditable


local function HasRequiredItem(src, itemName)
    if GetResourceState('tgiann-inventory') == 'started' then
        local hasItem = exports['tgiann-inventory']:HasItem(src, itemName, 1)
        if hasItem ~= nil then
            return hasItem
        end
    end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end

    local items = Player.PlayerData.items
    if not items then return false end

    for _, item in pairs(items) do
        if item and item.name == itemName and (item.amount or 0) > 0 then
            return true
        end
    end

    return false
end

RegisterNetEvent('panicbtn:server:tryTrigger', function()
    local src = source

    if not HasRequiredItem(src, Config.RequiredItem) then
        TriggerClientEvent('panicbtn:client:noGps', src)
        return
    end

    TriggerClientEvent('panicbtn:client:doTrigger', src)
end)