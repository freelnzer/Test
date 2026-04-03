-- db-base / client/client.lua
-- Allgemeiner Client-Einstiegspunkt

local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    if Config.Debug then
        print('^3[db-base]^7 Client gestartet. (Debug an)')
    end
end)

RegisterCommand("c3", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local text = string.format("vector3(%.2f, %.2f, %.2f)", coords.x, coords.y, coords.z)
    lib.setClipboard(text)

    print("Copied: " .. text)
end)

RegisterCommand("c4", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local text = string.format("vector4(%.2f, %.2f, %.2f, %.2f)", coords.x, coords.y, coords.z, heading)
    lib.setClipboard(text)

    print("Copied: " .. text)
end)

-- Panicbutton
RegisterCommand(Config.CommandName, function()
    TriggerServerEvent('panicbtn:server:tryTrigger')
end, false)

RegisterKeyMapping(Config.CommandName, 'Panic Button', 'keyboard', Config.DefaultKey)

RegisterNetEvent('panicbtn:client:menuTrigger', function()
    TriggerServerEvent('panicbtn:server:tryTrigger')
end)

RegisterNetEvent('panicbtn:client:doTrigger', function()
    TriggerEvent(Config.PanicEvent)
end)

RegisterNetEvent('panicbtn:client:noGps', function()
    local QBCore = exports['qb-core']:GetCoreObject()
    QBCore.Functions.Notify('Du hast kein GPS dabei.', 'error')
end)
-- Panicbutton