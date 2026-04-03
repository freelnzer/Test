-- db-base / client/sirenresponse.lua
-- NPCs reagieren nur auf Emergency-Fahrzeuge mit aktiver Sirene.
-- Verhalten:
-- - nur Fahrzeuge vor dem Emergency-Fahrzeug
-- - nur Fahrzeuge mit ähnlicher Fahrtrichtung
-- - erst sanft nach rechts ziehen
-- - danach leicht verlangsamen
-- - wenn unpassend: normal weiterfahren
-- - Debug-HUD + wenige 3D-Marker

if not Config.Modules.SirenResponse then return end

local cfg = Config.SirenResponse
local detectionThread = nil
local debugThread = nil

local reactedVehicles = {}

local debugState = {
    emergencySpeed = 0.0,
    candidates = 0,
    reacted = 0
}

local function vecDot(a, b)
    return (a.x * b.x) + (a.y * b.y) + (a.z * b.z)
end

local function vecLength(v)
    return math.sqrt((v.x * v.x) + (v.y * v.y) + (v.z * v.z))
end

local function normalize(v)
    local len = vecLength(v)
    if len <= 0.0001 then
        return vector3(0.0, 0.0, 0.0)
    end
    return vector3(v.x / len, v.y / len, v.z / len)
end

local function cleanupReactedVehicles(now)
    for veh, expireAt in pairs(reactedVehicles) do
        if not DoesEntityExist(veh) or now >= expireAt then
            reactedVehicles[veh] = nil
        end
    end
end

local function drawDebugHud()
    if not Config.Debug then return end

    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.32, 0.32)
    SetTextColour(255, 255, 255, 220)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(
        ("SirenResponse | Speed: %.0f km/h | Candidates: %d | Reacted: %d")
            :format(debugState.emergencySpeed, debugState.candidates, debugState.reacted)
    )
    DrawText(0.015, 0.015)
end

local function startDebugOverlay()
    if debugThread then return end

    debugThread = CreateThread(function()
        while Config.Modules.SirenResponse and Config.Debug do
            Wait(0)
            drawDebugHud()
        end

        debugThread = nil
    end)
end

local function isEmergencyVehicle(veh)
    if not DoesEntityExist(veh) then return false end
    return GetVehicleClass(veh) == 18
end

local function hasSirenActive(veh)
    if not DoesEntityExist(veh) then return false end
    return IsVehicleSirenOn(veh)
end

local function isEmergencyActive(veh)
    return isEmergencyVehicle(veh) and hasSirenActive(veh)
end

local function getNearbyNpcVehicles(centerPos, radius)
    local npcs = {}
    local vehicles = GetGamePool('CVehicle')

    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) and not IsEntityDead(veh) then
            local driver = GetPedInVehicleSeat(veh, -1)
            if driver ~= 0 and DoesEntityExist(driver) and not IsPedAPlayer(driver) then
                local vehPos = GetEntityCoords(veh)
                if #(centerPos - vehPos) <= radius then
                    npcs[#npcs + 1] = veh
                end
            end
        end
    end

    return npcs
end

local function isVehicleInFront(emergencyVeh, npcVeh)
    local emergencyPos = GetEntityCoords(emergencyVeh)
    local npcPos = GetEntityCoords(npcVeh)
    local forward = normalize(GetEntityForwardVector(emergencyVeh))
    local toNpc = normalize(npcPos - emergencyPos)

    local dot = vecDot(forward, toNpc)
    return dot >= (cfg.frontDotThreshold or 0.15), dot
end

local function isMovingSameDirection(emergencyVeh, npcVeh)
    local emergencyForward = normalize(GetEntityForwardVector(emergencyVeh))
    local npcForward = normalize(GetEntityForwardVector(npcVeh))

    local dot = vecDot(emergencyForward, npcForward)
    return dot >= (cfg.directionDotThreshold or 0.30), dot
end

local function shouldNpcReact(npcVeh, emergencyVeh)
    if not DoesEntityExist(npcVeh) or not DoesEntityExist(emergencyVeh) then
        return false
    end

    if npcVeh == emergencyVeh then
        return false
    end

    local driver = GetPedInVehicleSeat(npcVeh, -1)
    if driver == 0 or not DoesEntityExist(driver) then
        return false
    end

    local npcSpeed = GetEntitySpeed(npcVeh)
    if npcSpeed < (cfg.minNpcSpeed or 4.0) then
        return false
    end

    local inFront = select(1, isVehicleInFront(emergencyVeh, npcVeh))
    if not inFront then
        return false
    end

    local sameDirection = select(1, isMovingSameDirection(emergencyVeh, npcVeh))
    if not sameDirection then
        return false
    end

    return true
end

local function setTemporarySlowdown(veh)
    local currentSpeed = GetEntitySpeed(veh)
    if currentSpeed <= 1.0 then return end

    local factor = 1.0 - ((cfg.slowdownPercent or 8) / 100.0)
    local targetSpeed = currentSpeed * factor

    if targetSpeed < (cfg.minSlowSpeed or 6.0) then
        targetSpeed = cfg.minSlowSpeed or 6.0
    end

    SetVehicleMaxSpeed(veh, targetSpeed)

    SetTimeout(cfg.resetDelay or 1800, function()
        if DoesEntityExist(veh) then
            SetVehicleMaxSpeed(veh, 0.0)
        end
    end)
end

local function steerRightSoftly(veh, evadeDuration)
    local driver = GetPedInVehicleSeat(veh, -1)
    if driver == 0 or not DoesEntityExist(driver) then return end

    TaskVehicleTempAction(driver, veh, 6, evadeDuration)
end

local function getEmergencyTuning(emergencyVeh)
    local speedMs = GetEntitySpeed(emergencyVeh)
    local speedKmh = speedMs * 3.6

    local responseRadius = cfg.responseRadius or 45.0
    local evadeDuration = cfg.evadeDuration or 1000
    local slowdownDelay = cfg.slowdownDelay or 700

    if speedKmh >= 160.0 then
        responseRadius = responseRadius + 20.0
        evadeDuration = evadeDuration + 450
        slowdownDelay = slowdownDelay + 250
    elseif speedKmh >= 120.0 then
        responseRadius = responseRadius + 14.0
        evadeDuration = evadeDuration + 300
        slowdownDelay = slowdownDelay + 180
    elseif speedKmh >= 80.0 then
        responseRadius = responseRadius + 8.0
        evadeDuration = evadeDuration + 150
        slowdownDelay = slowdownDelay + 100
    end

    return {
        speedMs = speedMs,
        speedKmh = speedKmh,
        responseRadius = responseRadius,
        evadeDuration = evadeDuration,
        slowdownDelay = slowdownDelay
    }
end

local function applyRightSlowResponse(npcVeh, tuning)
    if not DoesEntityExist(npcVeh) then return end

    local now = GetGameTimer()
    local expireAt = reactedVehicles[npcVeh]
    if expireAt and now < expireAt then
        return
    end

    reactedVehicles[npcVeh] = now + (cfg.reactCooldown or 2800)

    steerRightSoftly(npcVeh, tuning.evadeDuration)

    SetTimeout(tuning.slowdownDelay, function()
        if DoesEntityExist(npcVeh) then
            setTemporarySlowdown(npcVeh)
        end
    end)
end

local function processEmergencyVehicle(emergencyVeh)
    local tuning = getEmergencyTuning(emergencyVeh)
    local emergencyPos = GetEntityCoords(emergencyVeh)
    local npcs = getNearbyNpcVehicles(emergencyPos, tuning.responseRadius)

    debugState.emergencySpeed = tuning.speedKmh
    debugState.candidates = #npcs
    debugState.reacted = 0

    for _, npcVeh in ipairs(npcs) do
        if shouldNpcReact(npcVeh, emergencyVeh) then
            debugState.reacted = debugState.reacted + 1
            applyRightSlowResponse(npcVeh, tuning)
        end
    end
end

local function startDetectionLoop()
    if detectionThread then return end

    detectionThread = CreateThread(function()
        while Config.Modules.SirenResponse do
            Wait(cfg.checkInterval or 350)

            local now = GetGameTimer()
            cleanupReactedVehicles(now)

            debugState.emergencySpeed = 0.0
            debugState.candidates = 0
            debugState.reacted = 0

            local playerPed = PlayerPedId()
            local playerPos = GetEntityCoords(playerPed)
            local allVehicles = GetGamePool('CVehicle')

            for _, veh in ipairs(allVehicles) do
                if DoesEntityExist(veh) then
                    local driver = GetPedInVehicleSeat(veh, -1)

                    if driver ~= 0 and DoesEntityExist(driver) and IsPedAPlayer(driver) then
                        if isEmergencyActive(veh) then
                            local vehPos = GetEntityCoords(veh)
                            local dist = #(playerPos - vehPos)

                            if dist <= (cfg.detectionRadius or 180.0) then
                                processEmergencyVehicle(veh)
                            end
                        end
                    end
                end
            end
        end

        detectionThread = nil
    end)
end

CreateThread(function()
    Wait(2000)

    if Config.Debug then
        startDebugOverlay()
    end

    startDetectionLoop()

    if Config.Debug then
        print("^2[db-base/SirenResponse]^7 Aktiv: nur Sirene / nur vorne / speed-adaptive / Debug HUD")
    end
end)