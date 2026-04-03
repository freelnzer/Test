local createdBlips = {}

local function CreateConfiguredBlip(entry)
    local coords = entry.coords
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, entry.sprite or 1)
    SetBlipDisplay(blip, entry.display or 4)
    SetBlipScale(blip, entry.scale or 0.8)
    SetBlipColour(blip, entry.color or 0)
    SetBlipAsShortRange(blip, entry.shortRange ~= false) -- default true

    if entry.category then
        SetBlipCategory(blip, entry.category)
    end

    if entry.route then
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, entry.color or 0)
    end

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(entry.name or 'Unnamed')
    EndTextCommandSetBlipName(blip)

    return blip
end

local function ClearAllConfiguredBlips()
    for i = 1, #createdBlips do
        local blip = createdBlips[i]
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end

    createdBlips = {}
end

local function InitBlips()
    local debugEnabled = Config.Debug
    local modules = Config.Modules
    local blipConfig = Config.Blips

    if not modules or not modules.Blips then
        if debugEnabled then
            print('^3[db-base]^7 Blips sind in Config.Modules deaktiviert.')
        end
        return
    end

    if type(blipConfig) ~= 'table' then
        if debugEnabled then
            print('^1[db-base]^7 Config.Blips fehlt oder ist ungültig!')
        end
        return
    end

    ClearAllConfiguredBlips()

    for i = 1, #blipConfig do
        local entry = blipConfig[i]

        if entry.enabled then
            local coords = entry.coords

            if coords and coords.x and coords.y and coords.z then
                local blip = CreateConfiguredBlip(entry)
                createdBlips[#createdBlips + 1] = blip

                if debugEnabled then
                    print(('^3[db-base]^7 Blip erstellt: %s @ (%.2f, %.2f, %.2f)'):format(
                        entry.name or 'Unnamed', coords.x, coords.y, coords.z
                    ))
                end
            elseif debugEnabled then
                print(('^1[db-base]^7 Ungültige Koordinaten für Blip: %s'):format(
                    entry.name or 'Unnamed'
                ))
            end
        end
    end
end

-- Initial beim Ressourcestart
CreateThread(function()
    Wait(500)
    InitBlips()
end)

RegisterNetEvent('db-base:client:reloadBlips', function()
    InitBlips()
end)