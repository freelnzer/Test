local QBCore = exports['qb-core']:GetCoreObject()

local holdingPad = false
local propObj = nil
local animDict = 'missheistdockssetup1clipboard@base'
local animName = 'base'

local function setFocus(state)
    SetNuiFocus(state, state)
    SetNuiFocusKeepInput(false)
end

local function loadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end

    RequestAnimDict(dict)

    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(10)
    end

    return true
end

local function startAnim()
    if holdingPad then return end

    local ped = PlayerPedId()
    if not loadAnimDict(animDict) then return end

    holdingPad = true
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 49, 0.0, false, false, false)

    local coords = GetEntityCoords(ped)
    local propHash = joaat(Config.Prop)

    if not HasModelLoaded(propHash) then
        RequestModel(propHash)
        local timeout = GetGameTimer() + 5000
        while not HasModelLoaded(propHash) do
            if GetGameTimer() > timeout then
                return
            end
            Wait(10)
        end
    end

    propObj = CreateObject(propHash, coords.x, coords.y, coords.z + 0.2, true, true, true)
    AttachEntityToEntity(
        propObj,
        ped,
        GetPedBoneIndex(ped, Config.PropBone),
        Config.PropPlacement.x,
        Config.PropPlacement.y,
        Config.PropPlacement.z,
        Config.PropPlacement.xRot,
        Config.PropPlacement.yRot,
        Config.PropPlacement.zRot,
        true,
        true,
        false,
        true,
        1,
        true
    )

    SetModelAsNoLongerNeeded(propHash)
end

local function stopAnim()
    if not holdingPad then return end

    holdingPad = false
    ClearPedTasks(PlayerPedId())

    if propObj and DoesEntityExist(propObj) then
        DeleteEntity(propObj)
    end

    propObj = nil
end

local function closeUi()
    setFocus(false)
    stopAnim()
    SendNUIMessage({ action = 'closeAll' })
end

RegisterNetEvent('andrew-notepad:client:openNotepad', function(draftText)
    Wait(150)
    startAnim()
    setFocus(true)

    SendNUIMessage({
        action = 'openNotepad',
        title = Config.UiTitle,
        placeholder = Config.UiPlaceholder,
        text = draftText or ''
    })
end)

RegisterNetEvent('andrew-notepad:client:readPaper', function(text)
    Wait(150)
    startAnim()
    setFocus(true)

    SendNUIMessage({
        action = 'readNote',
        text = text or ''
    })
end)

RegisterNUICallback('close', function(_, cb)
    closeUi()
    cb('ok')
end)

RegisterNUICallback('saveDraft', function(data, cb)
    TriggerServerEvent('andrew-notepad:server:saveDraft', data.text or '')
    cb('ok')
end)

RegisterNUICallback('tearPage', function(data, cb)
    TriggerServerEvent('andrew-notepad:server:createNote', data.text or '')
    cb('ok')
end)

RegisterNUICallback('notify', function(data, cb)
    if data and data.message and data.message ~= '' then
        QBCore.Functions.Notify(data.message, data.type or 'primary')
    end
    cb('ok')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    closeUi()
end)
