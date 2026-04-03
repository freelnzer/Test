local QBCore = exports['qb-core']:GetCoreObject()

local activeVehicles = {}
local activeWashPlaces = {}

local function getPrice(washType)
    if washType == 'standard' then
        return Config.PriceStandard
    elseif washType == 'lady' then
        return Config.PriceLady
    end

    return Config.PricePremium
end

local function getPlaceById(placeId)
    for _, place in pairs(Config.WashPlaces) do
        if place.id == placeId then
            return place
        end
    end
    return nil
end

local function clearPlayerSessions(src)
    for netId, owner in pairs(activeVehicles) do
        if owner == src then
            activeVehicles[netId] = nil
        end
    end

    for placeId, data in pairs(activeWashPlaces) do
        if data.owner == src then
            activeWashPlaces[placeId] = nil
            TriggerClientEvent('carwash:npcSync', -1, placeId, 'cleanup')
        end
    end
end

lib.callback.register('carwash:startWash', function(source, washType, netId, placeId)
    local src = source

    if not netId or netId == 0 then
        return false, 'invalid_vehicle'
    end

    if not placeId then
        return false, 'invalid_place'
    end

    local place = getPlaceById(placeId)
    if not place then
        return false, 'invalid_place'
    end

    if activeVehicles[netId] then
        return false, 'busy_vehicle'
    end

    if activeWashPlaces[placeId] then
        return false, 'busy_place'
    end

    local price = getPrice(washType)
    local hasMoney = false

    if Config.UseInventoryCashItem then
        local count = exports['tgiann-inventory']:GetItemCount(src, Config.InventoryCashItem) or 0
        if count >= price then
            hasMoney = exports['tgiann-inventory']:RemoveItem(src, Config.InventoryCashItem, price) and true or false
        end
    else
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.Functions.RemoveMoney('cash', price) then
            hasMoney = true
        end
    end

    if not hasMoney then
        return false, 'no_money'
    end

    activeVehicles[netId] = src
    activeWashPlaces[placeId] = {
        owner = src,
        netId = netId,
        washType = washType
    }

    TriggerClientEvent('carwash:npcSync', -1, placeId, 'start', washType)

    CreateThread(function()
        Wait(5000)
        if not activeWashPlaces[placeId] then return end
        TriggerClientEvent('carwash:npcSync', -1, placeId, 'phase2', washType)

        Wait(math.floor(Config.NPCwashTime * 0.5))
        if not activeWashPlaces[placeId] then return end
        TriggerClientEvent('carwash:npcSync', -1, placeId, 'water_on', washType)

        Wait(math.floor(Config.ParticleTime * 0.5))
        if not activeWashPlaces[placeId] then return end
        TriggerClientEvent('carwash:npcSync', -1, placeId, 'water_off_phase3', washType)

        Wait(math.floor(Config.NPCwashTime * 0.5))
        if not activeWashPlaces[placeId] then return end
        TriggerClientEvent('carwash:npcSync', -1, placeId, 'exit', washType)

        Wait(3000)
        if not activeWashPlaces[placeId] then return end
        TriggerClientEvent('carwash:npcSync', -1, placeId, 'cleanup')
    end)

    return true, 'ok'
end)

RegisterNetEvent('carwash:finishWash', function(netId, placeId, fullRepair)
    local src = source

    if not netId or netId == 0 then
        return
    end

    if activeVehicles[netId] ~= src then
        return
    end

    activeVehicles[netId] = nil

    if placeId and activeWashPlaces[placeId] and activeWashPlaces[placeId].owner == src then
        activeWashPlaces[placeId] = nil
        TriggerClientEvent('carwash:npcSync', -1, placeId, 'cleanup')
    end

    TriggerClientEvent('carwash:applyWash', src, netId, fullRepair == true)
    TriggerClientEvent('carwash:syncWash', -1, netId, fullRepair == true)
end)

RegisterNetEvent('carwash:cancelWash', function(netId, placeId)
    local src = source

    if not netId or netId == 0 then
        return
    end

    if activeVehicles[netId] == src then
        activeVehicles[netId] = nil
    end

    if placeId and activeWashPlaces[placeId] and activeWashPlaces[placeId].owner == src then
        activeWashPlaces[placeId] = nil
        TriggerClientEvent('carwash:npcSync', -1, placeId, 'cleanup')
    end
end)

AddEventHandler('playerDropped', function()
    clearPlayerSessions(source)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    for placeId, _ in pairs(activeWashPlaces) do
        TriggerClientEvent('carwash:npcSync', -1, placeId, 'cleanup')
    end

    activeVehicles = {}
    activeWashPlaces = {}
end)