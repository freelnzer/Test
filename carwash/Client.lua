local QBCore = exports['qb-core']:GetCoreObject()

local washing = false
local textUiOpen = false
local syncedScenes = {}

local function notify(msg, typ)
    lib.notify({
        description = msg,
        type = typ or 'inform'
    })
end

local function showUi(text)
    if not textUiOpen then
        lib.showTextUI(text)
        textUiOpen = true
    end
end

local function hideUi()
    if textUiOpen then
        lib.hideTextUI()
        textUiOpen = false
    end
end

local function getPlaceById(placeId)
    for _, place in pairs(Config.WashPlaces) do
        if place.id == placeId then
            return place
        end
    end
    return nil
end

local function requestModel(model)
    local hash = type(model) == 'string' and joaat(model) or model
    if not IsModelInCdimage(hash) then return nil end

    RequestModel(hash)

    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Wait(50)
        if GetGameTimer() > timeout then
            return nil
        end
    end

    return hash
end

local function requestPtfx(dict)
    RequestNamedPtfxAsset(dict)

    local timeout = GetGameTimer() + 5000
    while not HasNamedPtfxAssetLoaded(dict) do
        Wait(50)
        if GetGameTimer() > timeout then
            return false
        end
    end

    return true
end

local function ensureScene(placeId)
    if not syncedScenes[placeId] then
        syncedScenes[placeId] = {
            peds = {},
            particles = {}
        }
    end

    return syncedScenes[placeId]
end

local function stopWaterFx(placeId)
    local scene = syncedScenes[placeId]
    if not scene then return end

    for i = 1, #scene.particles do
        local ptfx = scene.particles[i]
        if ptfx then
            StopParticleFxLooped(ptfx, false)
        end
    end

    scene.particles = {}
end

local function cleanupScene(placeId)
    local scene = syncedScenes[placeId]
    if not scene then return end

    stopWaterFx(placeId)

    for i = 1, #scene.peds do
        local ped = scene.peds[i]
        if DoesEntityExist(ped) then
            ClearPedTasksImmediately(ped)
            DeleteEntity(ped)
        end
    end

    syncedScenes[placeId] = nil
end

local function cleanupAllScenes()
    for placeId, _ in pairs(syncedScenes) do
        cleanupScene(placeId)
    end
end

local function createScenePed(model, coords)
    local hash = requestModel(model)
    if not hash then return nil end

    local ped = CreatePed(4, hash, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
    if not DoesEntityExist(ped) then
        SetModelAsNoLongerNeeded(hash)
        return nil
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedCanBeTargetted(ped, false)
    SetEntityInvincible(ped, true)

    SetModelAsNoLongerNeeded(hash)
    return ped
end

local function startWaterFx(placeId, place)
    local scene = ensureScene(placeId)
    if not requestPtfx('core') then return end

    UseParticleFxAssetNextCall('core')
    local p1 = StartParticleFxLoopedAtCoord(
        'ent_amb_waterfall_splash_p',
        place.carPos.x,
        place.carPos.y,
        place.carPos.z + 0.8,
        0.0, 0.0, 90.0,
        1.0,
        false, false, false, false
    )

    UseParticleFxAssetNextCall('core')
    local p2 = StartParticleFxLoopedAtCoord(
        'ent_amb_waterfall_splash_p',
        place.carPos.x + 2.0,
        place.carPos.y,
        place.carPos.z + 0.8,
        0.0, 0.0, 90.0,
        1.0,
        false, false, false, false
    )

    scene.particles[#scene.particles + 1] = p1
    scene.particles[#scene.particles + 1] = p2
end

local function spawnScenePeds(placeId, washType)
    local place = getPlaceById(placeId)
    if not place or not Config.EnableCosmeticNPCs or not place.npc or not place.npc.enabled then
        return
    end

    cleanupScene(placeId)

    local scene = ensureScene(placeId)
    local npcCfg = place.npc
    local model
    if washType == 'standard' then
        model = npcCfg.modelStandard
    elseif washType == 'lady' then
        model = npcCfg.modelLady
    else
        model = npcCfg.modelPremium
    end

    local ped1 = createScenePed(model, npcCfg.spawn1)
    local ped2 = createScenePed(model, npcCfg.spawn2)

    if ped1 then
        scene.peds[#scene.peds + 1] = ped1
        TaskGoStraightToCoord(ped1, npcCfg.clean1.x, npcCfg.clean1.y, npcCfg.clean1.z, 1.0, 8000, npcCfg.clean1.w, 0.0)
    end

    if ped2 then
        scene.peds[#scene.peds + 1] = ped2
        TaskGoStraightToCoord(ped2, npcCfg.clean3.x, npcCfg.clean3.y, npcCfg.clean3.z, 1.0, 8000, npcCfg.clean3.w, 0.0)
    end
end

local function setSceneToPhase2(placeId)
    local place = getPlaceById(placeId)
    local scene = syncedScenes[placeId]
    if not place or not scene then return end

    local npcCfg = place.npc
    local ped1 = scene.peds[1]
    local ped2 = scene.peds[2]

    if ped1 and DoesEntityExist(ped1) then
        SetEntityHeading(ped1, npcCfg.clean1.w)
        TaskStartScenarioInPlace(ped1, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
    end

    if ped2 and DoesEntityExist(ped2) then
        SetEntityHeading(ped2, npcCfg.clean3.w)
        TaskStartScenarioInPlace(ped2, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
    end
end

local function setSceneToPhase3(placeId)
    local place = getPlaceById(placeId)
    local scene = syncedScenes[placeId]
    if not place or not scene then return end

    local npcCfg = place.npc
    local ped1 = scene.peds[1]
    local ped2 = scene.peds[2]

    if ped1 and DoesEntityExist(ped1) then
        ClearPedTasksImmediately(ped1)
        TaskGoStraightToCoord(ped1, npcCfg.clean2.x, npcCfg.clean2.y, npcCfg.clean2.z, 1.0, 8000, npcCfg.clean2.w, 0.0)
    end

    if ped2 and DoesEntityExist(ped2) then
        ClearPedTasksImmediately(ped2)
        TaskGoStraightToCoord(ped2, npcCfg.clean4.x, npcCfg.clean4.y, npcCfg.clean4.z, 1.0, 8000, npcCfg.clean4.w, 0.0)
    end
end

local function setSceneToPhase4(placeId)
    local place = getPlaceById(placeId)
    local scene = syncedScenes[placeId]
    if not place or not scene then return end

    local npcCfg = place.npc
    local ped1 = scene.peds[1]
    local ped2 = scene.peds[2]

    if ped1 and DoesEntityExist(ped1) then
        SetEntityHeading(ped1, npcCfg.clean2.w)
        TaskStartScenarioInPlace(ped1, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
    end

    if ped2 and DoesEntityExist(ped2) then
        SetEntityHeading(ped2, npcCfg.clean4.w)
        TaskStartScenarioInPlace(ped2, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
    end
end

local function setSceneExit(placeId)
    local place = getPlaceById(placeId)
    local scene = syncedScenes[placeId]
    if not place or not scene then return end

    local npcCfg = place.npc
    local ped1 = scene.peds[1]
    local ped2 = scene.peds[2]

    if ped1 and DoesEntityExist(ped1) then
        ClearPedTasksImmediately(ped1)
        TaskGoStraightToCoord(ped1, npcCfg.exit1.x, npcCfg.exit1.y, npcCfg.exit1.z, 1.0, 8000, npcCfg.exit1.w, 0.0)
    end

    if ped2 and DoesEntityExist(ped2) then
        ClearPedTasksImmediately(ped2)
        TaskGoStraightToCoord(ped2, npcCfg.exit2.x, npcCfg.exit2.y, npcCfg.exit2.z, 1.0, 8000, npcCfg.exit2.w, 0.0)
    end
end

function openWashMenu(place)
    if washing then return end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        notify('Du musst im Auto sein', 'error')
        return
    end

    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        notify('Du musst Fahrer sein', 'error')
        return
    end

    local input = lib.inputDialog(Lang['wash_menu'], {
        {
            type = 'select',
            label = 'Service',
            required = true,
            options = {
                { value = 'standard', label = ('%s %s$'):format(Lang['wash_car1'], Config.PriceStandard) },
                { value = 'premium', label = ('%s %s$'):format(Lang['wash_car2'], Config.PricePremium) },
                { value = 'lady', label = ('%s %s$'):format(Lang['wash_car3'], Config.PriceLady) },
            }
        }
    })

    if not input or not input[1] then
        return
    end

    startWash(place, input[1])
end

function startWash(place, washType)
    if washing then return end

    if not place.id then
        notify('Waschplatz-ID fehlt in der Config', 'error')
        return
    end

    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        notify('Kein Fahrzeug gefunden', 'error')
        return
    end

    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        notify('Du musst Fahrer sein', 'error')
        return
    end

    local bodyHealth = GetVehicleBodyHealth(vehicle)
    if bodyHealth < Config.DamageMin then
        notify('Fahrzeug zu beschädigt', 'error')
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then
        notify('Fahrzeug konnte nicht synchronisiert werden', 'error')
        return
    end

    local ok = lib.callback.await('carwash:startWash', false, washType, netId, place.id)
    if not ok then
        notify('Nicht genug Geld oder Fahrzeug/Waschplatz bereits belegt', 'error')
        return
    end

    washing = true
    hideUi()

    SetEntityCoords(vehicle, place.carPos.x, place.carPos.y, place.carPos.z, false, false, false, false)
    SetEntityHeading(vehicle, place.carHeading)
    SetVehicleOnGroundProperly(vehicle)
    FreezeEntityPosition(vehicle, true)

    local finished = lib.progressCircle({
        duration = Config.NPCwashTime + Config.ParticleTime + 4000,
        label = 'Fahrzeug wird gewaschen...',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    })

    if not finished then
        TriggerServerEvent('carwash:cancelWash', netId, place.id)
        cleanupAllScenes()
        FreezeEntityPosition(vehicle, false)
        washing = false
        return
    end

    local fullRepair = washType == 'premium' or washType == 'lady'
    TriggerServerEvent('carwash:finishWash', netId, place.id, fullRepair)

    FreezeEntityPosition(vehicle, false)
    cleanupAllScenes()
    washing = false

    if fullRepair then
        notify('Fahrzeug komplett gewaschen und repariert', 'success')
    else
        notify('Fahrzeug gewaschen', 'success')
    end
end

CreateThread(function()
    while true do
        local sleep = 1500

        if not washing then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            for _, place in pairs(Config.WashPlaces) do
                local dist = #(coords - place.pos)

                if dist < 20.0 then
                    sleep = 0

                    DrawMarker(
                        27,
                        place.pos.x, place.pos.y, place.pos.z - 0.95,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        1.5, 1.5, 1.0,
                        60, 180, 75, 180,
                        false, true, 2, false, nil, nil, false
                    )

                    if dist <= 4.5 then
                        local vehicle = GetVehiclePedIsIn(ped, false)

                        if vehicle ~= 0 then
                            if GetPedInVehicleSeat(vehicle, -1) == ped then
                                showUi('[E] Waschanlage öffnen')

                                if IsControlJustPressed(0, 38) then
                                    openWashMenu(place)
                                end
                            else
                                showUi('Du musst Fahrer sein')
                            end
                        else
                            showUi('Du musst im Auto sein')
                        end
                    else
                        hideUi()
                    end
                end
            end
        else
            hideUi()
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('carwash:npcSync', function(placeId, phase, washType)
    local place = getPlaceById(placeId)
    if not place then return end
    if not Config.EnableCosmeticNPCs or not place.npc or not place.npc.enabled then return end

    if phase == 'start' then
        spawnScenePeds(placeId, washType)
    elseif phase == 'phase2' then
        setSceneToPhase2(placeId)
    elseif phase == 'water_on' then
        stopWaterFx(placeId)
        startWaterFx(placeId, place)
        setSceneToPhase3(placeId)
    elseif phase == 'water_off_phase3' then
        stopWaterFx(placeId)
        setSceneToPhase4(placeId)
    elseif phase == 'exit' then
        setSceneExit(placeId)
    elseif phase == 'cleanup' then
        cleanupScene(placeId)
    end
end)

RegisterNetEvent('carwash:applyWash', function(netId, fullRepair)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 then return end
    if not DoesEntityExist(vehicle) then return end

    SetVehicleDirtLevel(vehicle, 0.0)
    WashDecalsFromVehicle(vehicle, 1.0)

    if fullRepair then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
    else
        SetVehicleBodyHealth(vehicle, math.max(GetVehicleBodyHealth(vehicle), 1000.0))
    end
end)

RegisterNetEvent('carwash:syncWash', function(netId, fullRepair)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 then return end
    if not DoesEntityExist(vehicle) then return end

    SetVehicleDirtLevel(vehicle, 0.0)
    WashDecalsFromVehicle(vehicle, 1.0)

    if fullRepair then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
    end
end)

CreateThread(function()
    if not Config.EnableBlips then return end

    for _, place in pairs(Config.WashPlaces) do
        local blip = AddBlipForCoord(place.pos.x, place.pos.y, place.pos.z)

        SetBlipSprite(blip, Config.BlipSprite or 100)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.BlipScale or 0.8)
        SetBlipColour(blip, Config.BlipColor or 2)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.BlipName or 'Waschanlage')
        EndTextCommandSetBlipName(blip)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    cleanupAllScenes()
    hideUi()
end)