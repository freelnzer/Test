local QBCore = exports['qb-core']:GetCoreObject()

local function getPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

local function normalizeText(text)
    if type(text) ~= 'string' then
        return ''
    end

    text = text:gsub('^%s+', ''):gsub('%s+$', '')

    if #text > Config.MaxNoteLength then
        text = text:sub(1, Config.MaxNoteLength)
    end

    return text
end

local function makeLabel(text)
    if text == '' then
        return 'Leere Notiz'
    end

    local singleLine = text:gsub('[\r\n]+', ' ')
    if #singleLine <= Config.MaxLabelLength then
        return ('Notiz: %s'):format(singleLine)
    end

    return ('Notiz: %s...'):format(singleLine:sub(1, Config.MaxLabelLength))
end

local function getDraft(player)
    local metadata = player.PlayerData.metadata or {}
    return metadata[Config.DraftMetadataKey] or ''
end

local function setDraft(player, text)
    player.Functions.SetMetaData(Config.DraftMetadataKey, text)
end

QBCore.Functions.CreateUseableItem(Config.NotepadItem, function(source)
    local player = getPlayer(source)
    if not player then return end

    TriggerClientEvent('andrew-notepad:client:openNotepad', source, getDraft(player))
end)

QBCore.Functions.CreateUseableItem(Config.PaperItem, function(source, item)
    local noteText = 'Unleserlich...'

    if item and item.info then
        if item.info.note and item.info.note ~= '' then
            noteText = item.info.note
        elseif item.info.label and item.info.label ~= '' then
            noteText = item.info.label
        end
    end

    TriggerClientEvent('andrew-notepad:client:readPaper', source, noteText)
end)

RegisterNetEvent('andrew-notepad:server:saveDraft', function(text)
    local src = source
    local player = getPlayer(src)
    if not player then return end

    if not player.Functions.GetItemByName(Config.NotepadItem) then
        TriggerClientEvent('QBCore:Notify', src, 'Du hast keinen Block.', 'error')
        return
    end

    local draftText = normalizeText(text)
    setDraft(player, draftText)

    TriggerClientEvent('QBCore:Notify', src, 'Notiz gespeichert.', 'success')
end)

RegisterNetEvent('andrew-notepad:server:createNote', function(text)
    local src = source
    local player = getPlayer(src)
    if not player then return end

    if not player.Functions.GetItemByName(Config.NotepadItem) then
        TriggerClientEvent('QBCore:Notify', src, 'Du hast keinen Block.', 'error')
        return
    end

    local noteText = normalizeText(text)
    if noteText == '' then
        TriggerClientEvent('QBCore:Notify', src, 'Die Notiz ist leer.', 'error')
        return
    end

    setDraft(player, noteText)

    local info = {
        note = noteText,
        label = makeLabel(noteText),
        type = 'item'
    }

    local success = player.Functions.AddItem(Config.PaperItem, 1, false, info)
    if not success then
        TriggerClientEvent('QBCore:Notify', src, 'Inventar voll.', 'error')
        return
    end

    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.PaperItem], 'add')
    TriggerClientEvent('QBCore:Notify', src, 'Seite wurde abgerissen.', 'success')
end)
