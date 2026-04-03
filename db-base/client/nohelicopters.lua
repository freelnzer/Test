-- db-base / client/nohelicopters.lua

local function SafeDelete(entity)
    if not DoesEntityExist(entity) then return end
    NetworkRequestControlOfEntity(entity)
    SetEntityAsMissionEntity(entity, true, true)
    DeleteEntity(entity)
end

local function VehicleHasAnyPlayer(veh)
    for seat = -1, GetVehicleMaxNumberOfPassengers(veh) do
        local occ = GetPedInVehicleSeat(veh, seat)
        if occ and occ ~= 0 and IsPedAPlayer(occ) then
            return true
        end
    end
    return false
end

local function DeleteHelicopterWithOccupants(veh)
    for seat = -1, GetVehicleMaxNumberOfPassengers(veh) do
        local occ = GetPedInVehicleSeat(veh, seat)
        if occ and occ ~= 0 then
            SafeDelete(occ)
        end
    end
    SafeDelete(veh)
end

CreateThread(function()
    if not Config.Modules.NoNpcHelicopters then return end

    while true do
        Wait(1500)

        for _, veh in ipairs(GetGamePool('CVehicle')) do
            if GetVehicleClass(veh) == 15
            and not IsEntityAMissionEntity(veh)
            and not VehicleHasAnyPlayer(veh) then

                local driver = GetPedInVehicleSeat(veh, -1)

                if driver == 0 or (driver ~= 0 and not IsPedAPlayer(driver)) then
                    if Config.Debug then
                        local coords = GetEntityCoords(veh)
                        local label  = driver == 0 and 'Leerer' or 'NPC'
                        print(('^3[db-base]^7 %s-Helikopter entfernt @ (%.2f, %.2f, %.2f)'):format(
                            label, coords.x, coords.y, coords.z
                        ))
                    end
                    DeleteHelicopterWithOccupants(veh)
                end
            end
        end
    end
end)