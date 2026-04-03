-- db-base / client/hairstyle.lua
-- Öffnet den Friseursalon (nur Frisur) von tgiann-clothing per Item-Benutzung oder Befehl.

if not Config.Modules.Hairstyle then return end

local QBCore = exports['qb-core']:GetCoreObject()

local function openHairstyleMenu()
    local ped = PlayerPedId()

    if Config.Hairstyle.notification then
        QBCore.Functions.Notify(Config.Hairstyle.notifyText, 'primary', 3000)
    end

    -- Charakter führt kurze Grooming-Pose aus (zuverlässiges GTA5-Scenario)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    Wait(2500)
    ClearPedTasksImmediately(ped)

    -- Öffnet nur das Frisur-Menü (kein Kleidungs- oder Tattoo-Tab)
    exports['tgiann-clothing']:OpenWardobeMenu('barber')
end

-- Server schickt dieses Event wenn das Item benutzt wird
RegisterNetEvent('db-base:client:openHairstyle', function()
    openHairstyleMenu()
end)

-- Befehl: /frisierset
RegisterCommand('frisierset', function()
    openHairstyleMenu()
end, false)
