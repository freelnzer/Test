local QBCore = exports['qb-core']:GetCoreObject()

local NoNpcConfig = Config.NoNpcSettings or {}

local activeZones = {}
local nearbyZones = {}
local playerNearRelevantZone = false

local function DebugPrint(msg)
    if Config.Debug or NoNpcConfig.debugLog then
        print(('^3[db-base][NoNPC]^7 %s'):format(msg))
    end
end

local function RequestControl(entity, timeout)
    timeout = timeout or 1000
    if not DoesEntityExist(entity) then return false end

    local start = GetGameTimer()
    NetworkRequestControlOfEntity(entity)

    while DoesEntityExist(entity)
    and not NetworkHasControlOfEntity(entity)
    and (GetGameTimer() - start) < timeout do
        Wait(0)
        NetworkRequestControlOfEntity(entity)
    end

    return NetworkHasControlOfEntity(entity)
end

local function SafeDelete(entity)
    if not DoesEntityExist(entity) then return false end

    if not RequestControl(entity, 1000) then 
        return false 
    end

    SetEntityAsMissionEntity(entity, true, true)

    if IsEntityAPed(entity) then
        --ClearPedTasksImmediately(entity)
        DeletePed(entity)
    elseif IsEntityAVehicle(entity) then
        DeleteVehicle(entity)
    else
        DeleteEntity(entity)
    end

    return not DoesEntityExist(entity)
end

local function VehicleHasAnyPlayer(veh)
    if not DoesEntityExist(veh) then return false end
    for seat = -1, GetVehicleMaxNumberOfPassengers(veh) do
        local occ = GetPedInVehicleSeat(veh, seat)
        if occ and occ ~= 0 and IsPedAPlayer(occ) then
            return true
        end
    end
    return false
end

local function IsAmbientPed(ped)
    if not DoesEntityExist(ped) then return false end
    if IsPedAPlayer(ped) then return false end

    local popType = GetEntityPopulationType(ped)
    if popType == 7 then return false end

    return true
end

local function IsAmbientVehicle(veh)
    if not DoesEntityExist(veh) then return false end
    if VehicleHasAnyPlayer(veh) then return false end
    if IsEntityAMissionEntity(veh) then return false end
    return true
end

local function GetXY(point)
    return point.x or point[1], point.y or point[2]
end

local function BuildPolygonZone(zoneData, derivedMinZ, derivedMaxZ)
    local points = zoneData.points
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local sumX, sumY = 0.0, 0.0

    for _, p in ipairs(points) do
        local x, y = GetXY(p)
        minX = math.min(minX, x)
        minY = math.min(minY, y)
        maxX = math.max(maxX, x)
        maxY = math.max(maxY, y)
        sumX = sumX + x
        sumY = sumY + y
    end

    local center = vector3(
        sumX / #points,
        sumY / #points,
        ((derivedMinZ or 0.0) + (derivedMaxZ or 0.0)) / 2.0
    )

    local boundRadius = 0.0
    for _, p in ipairs(points) do
        local x, y = GetXY(p)
        local dist = #(vector2(center.x, center.y) - vector2(x, y))
        if dist > boundRadius then boundRadius = dist end
    end

    local zone = {
        kind        = 'poly',
        points      = points,
        minZ        = derivedMinZ,
        maxZ        = derivedMaxZ,
        center      = center,
        boundRadius = boundRadius,
        minX        = minX,
        minY        = minY,
        maxX        = maxX,
        maxY        = maxY,
    }

    function zone:isPointInside(point)
        if self.minZ and point.z < self.minZ then return false end
        if self.maxZ and point.z > self.maxZ then return false end

        local point2  = vector2(point.x, point.y)
        local center2 = vector2(self.center.x, self.center.y)
        if #(point2 - center2) > (self.boundRadius + 2.0) then return false end

        local oddNodes = false
        local j = #self.points
        for i = 1, #self.points do
            local pI = self.points[i]
            local pJ = self.points[j]
            local iX, iY = GetXY(pI)
            local jX, jY = GetXY(pJ)
            if (iY < point.y and jY >= point.y) or (jY < point.y and iY >= point.y) then
                local slope = iX + ((point.y - iY) / (jY - iY)) * (jX - iX)
                if slope < point.x then oddNodes = not oddNodes end
            end
            j = i
        end
        return oddNodes
    end

    function zone:getDistance2D(point)
        return #(vector2(point.x, point.y) - vector2(self.center.x, self.center.y))
    end

    return zone
end

local function BuildCircleZone(zoneData)
    local zone = {
        kind        = 'circle',
        coords      = zoneData.coords,
        radius      = zoneData.radius,
        center      = zoneData.coords,
        boundRadius = zoneData.radius,
    }

    function zone:isPointInside(point)
        return #(point - self.coords) <= self.radius
    end

    function zone:getDistance2D(point)
        return #(vector2(point.x, point.y) - vector2(self.coords.x, self.coords.y))
    end

    return zone
end

local function RegisterPopulationSuppression(zone)
    local pedMultiplier = zone.removePeds    and 0.0 or 1.0
    local vehMultiplier = zone.removeVehicles and 0.0 or 1.0

    if zone.kind == 'poly' then
        local minZ = zone.minZ or -500.0
        local maxZ = zone.maxZ or  500.0

        zone.popId = AddPopMultiplierArea(
            zone.minX, zone.minY, minZ,
            zone.maxX, zone.maxY, maxZ,
            pedMultiplier, vehMultiplier,
            false, false
        )

        if zone.removeVehicles then
            RemoveVehiclesFromGeneratorsInArea(zone.minX, zone.minY, minZ, zone.maxX, zone.maxY, maxZ)
        end
    else
        zone.popId = AddPopMultiplierSphere(
            zone.coords.x, zone.coords.y, zone.coords.z,
            zone.radius,
            pedMultiplier, vehMultiplier,
            false, false
        )

        if zone.removeVehicles then
            RemoveVehiclesFromGeneratorsInArea(
                zone.coords.x - zone.radius, zone.coords.y - zone.radius, zone.coords.z - zone.radius,
                zone.coords.x + zone.radius, zone.coords.y + zone.radius, zone.coords.z + zone.radius
            )
        end
    end
end

local function BuildActiveZones()
    activeZones = {}
    local rawZones = Config.NoNpcZones or {}

    for i, zoneData in ipairs(rawZones) do
        if zoneData.enabled then
            local derivedMinZ = zoneData.minZ
            local derivedMaxZ = zoneData.maxZ
            local zone        = nil

            if zoneData.points and #zoneData.points > 0 then
                if not derivedMinZ or not derivedMaxZ then
                    local zMin, zMax = nil, nil
                    for _, point in ipairs(zoneData.points) do
                        local z = point.z
                        if z then
                            zMin = zMin and math.min(zMin, z) or z
                            zMax = zMax and math.max(zMax, z) or z
                        end
                    end
                    if zMin and zMax then
                        derivedMinZ = derivedMinZ or (zMin - 15.0)
                        derivedMaxZ = derivedMaxZ or (zMax + 15.0)
                    end
                end
                zone = BuildPolygonZone(zoneData, derivedMinZ, derivedMaxZ)

            elseif zoneData.coords and zoneData.radius then
                zone = BuildCircleZone(zoneData)
            end

            if zone then
                zone.index          = i
                zone.name           = zoneData.name or ('NoNpcZone #%s'):format(i)
                zone.debugPoly      = zoneData.debugPoly == true
                zone.removePeds     = zoneData.removePeds    ~= false
                zone.removeVehicles = zoneData.removeVehicles ~= false
                zone.triggerDistance = (zone.boundRadius or 0.0) + (NoNpcConfig.activationDistance or 120.0)
                RegisterPopulationSuppression(zone)
                activeZones[#activeZones + 1] = zone
                DebugPrint(('Zone geladen: %s'):format(zone.name))
            end
        end
    end
end

local function ShouldDrawZoneDebug(zone)
    if not NoNpcConfig.enableDebugDraw then return false end
    if NoNpcConfig.forceDebugAllZones   then return true  end
    return zone.debugPoly or Config.Debug
end

local function RefreshNearbyZones()
    nearbyZones = {}
    playerNearRelevantZone = false
    if #activeZones == 0 then return end

    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, zone in ipairs(activeZones) do
        if zone:getDistance2D(playerCoords) <= zone.triggerDistance then
            nearbyZones[#nearbyZones + 1] = zone
            playerNearRelevantZone = true
        end
    end
end

CreateThread(function()
    while not Config.Modules.NoNpcZones do Wait(1000) end
    BuildActiveZones()
    RefreshNearbyZones()
end)

CreateThread(function()
    while true do
        if #activeZones == 0 then
            Wait(2000)
        else
            RefreshNearbyZones()
            Wait(playerNearRelevantZone
                and (NoNpcConfig.nearRefreshInterval   or  500)
                or  (NoNpcConfig.idleRefreshInterval   or 2500))
        end
    end
end)

CreateThread(function()
    while true do
        if not playerNearRelevantZone or #nearbyZones == 0 then
            Wait(NoNpcConfig.idleCleanupInterval or 2500)
        else
            local playerCoords = GetEntityCoords(PlayerPedId())
            local pedRadius    = NoNpcConfig.pedScanRadius     or 140.0
            local vehRadius    = NoNpcConfig.vehicleScanRadius or 180.0

            -- Peds
            for _, ped in ipairs(GetGamePool('CPed')) do
                if IsAmbientPed(ped) then
                    local c = GetEntityCoords(ped)
                    if #(c - playerCoords) <= pedRadius then
                        for _, zone in ipairs(nearbyZones) do
                            if zone.removePeds and zone:isPointInside(c) then
                                if IsPedInAnyVehicle(ped, false) then
                                    local veh = GetVehiclePedIsIn(ped, false)
                                    if zone.removeVehicles
                                    and DoesEntityExist(veh)
                                    and GetPedInVehicleSeat(veh, -1) == ped
                                    and not VehicleHasAnyPlayer(veh) then
                                        SafeDelete(veh)
                                    end
                                end
                                SafeDelete(ped)
                                break
                            end
                        end
                    end
                end
            end

            -- Vehicles
            for _, veh in ipairs(GetGamePool('CVehicle')) do
                if IsAmbientVehicle(veh) then
                    local c = GetEntityCoords(veh)
                    if #(c - playerCoords) <= vehRadius then
                        for _, zone in ipairs(nearbyZones) do
                            if zone.removeVehicles and zone:isPointInside(c) then
                                SafeDelete(veh)
                                break
                            end
                        end
                    end
                end
            end

            Wait(NoNpcConfig.activePedCleanupInterval or 700)
        end
    end
end)


CreateThread(function()
    while true do
        if #activeZones == 0 or not NoNpcConfig.enableDebugDraw then
            Wait(5000)
        else
            local sleep         = 1500
            local playerCoords  = GetEntityCoords(PlayerPedId())
            local renderDistance = NoNpcConfig.debugDrawDistance or 200.0

            for _, zone in ipairs(activeZones) do
                if ShouldDrawZoneDebug(zone) then
                    local dist2D = zone:getDistance2D(playerCoords)
                    if dist2D <= (renderDistance + (zone.boundRadius or 0.0)) then
                        sleep = 0

                        local isInside = zone:isPointInside(playerCoords)
                        local r = isInside and 0   or 255
                        local g = isInside and 255 or 80
                        local b = 0
                        local a = NoNpcConfig.debugAlpha or 90

                        if zone.kind == 'circle' then
                            DrawMarker(
                                28,
                                zone.coords.x, zone.coords.y, zone.coords.z,
                                0.0, 0.0, 0.0,
                                0.0, 0.0, 0.0,
                                zone.radius * 2.0, zone.radius * 2.0,
                                math.max((zone.maxZ and zone.minZ) and (zone.maxZ - zone.minZ) or 2.0, 2.0),
                                r, g, b, a,
                                false, false, 2, false, nil, nil, false
                            )
                            DrawLine(zone.coords.x, zone.coords.y, zone.coords.z, playerCoords.x, playerCoords.y, playerCoords.z, 255, 255, 255, 120)

                        elseif zone.points and #zone.points > 1 then
                            local minZ = zone.minZ or (playerCoords.z - 5.0)
                            local maxZ = zone.maxZ or (playerCoords.z + 5.0)

                            for idx = 1, #zone.points do
                                local p1 = zone.points[idx]
                                local p2 = zone.points[idx + 1] or zone.points[1]
                                local x1, y1 = GetXY(p1)
                                local x2, y2 = GetXY(p2)

                                DrawPoly(x1, y1, minZ, x2, y2, minZ, x2, y2, maxZ, r, g, b, a)
                                DrawPoly(x1, y1, minZ, x2, y2, maxZ, x1, y1, maxZ, r, g, b, a)
                                DrawLine(x1, y1, minZ, x2, y2, minZ, 255, 255, 255, 220)
                                DrawLine(x1, y1, maxZ, x2, y2, maxZ, 255, 255, 255, 220)
                                DrawLine(x1, y1, minZ, x1, y1, maxZ, 255, 255, 255, 160)
                            end

                            DrawLine(zone.center.x, zone.center.y, (zone.minZ or playerCoords.z), playerCoords.x, playerCoords.y, playerCoords.z, 255, 255, 255, 120)
                        end
                    end
                end
            end

            Wait(sleep)
        end
    end
end)