local ALLOWED_CUFF_TYPES = {
    handcuffs = true,
    cable_ties = true
}

local function setPlayerUncuffed(targetId)
    targetId = tonumber(targetId)
    if not targetId then
        return false, 'Ungültige Spieler-ID.'
    end

    local playerObj = Player(targetId)
    if not playerObj then
        return false, 'Spieler nicht gefunden.'
    end

    local isCuffed = playerObj.state.isCuffed
    local cuffType = playerObj.state.cuffType
    local draggedBy = playerObj.state.draggedBy

    if not isCuffed then
        return false, 'Spieler ist nicht gefesselt.'
    end

    if not ALLOWED_CUFF_TYPES[cuffType] then
        return false, ('Falscher Fesseltyp: %s'):format(tostring(cuffType))
    end

    playerObj.state:set('isCuffed', false, true)
    playerObj.state:set('cuffType', false, true)
    playerObj.state:set('draggedBy', 0, true)

    TriggerClientEvent('p_policejob:ForceUncuff', targetId)
    TriggerClientEvent('p_policejob:ForceUncuffCleanup', targetId)

    return true
end

RegisterCommand('uncuff', function(source, args)

    local targetId = tonumber(args[1])
    if not targetId then
        local msg = '^1Verwendung:^7 /uncuff [id]'
        if source == 0 then
            print(msg:gsub('%^%d', ''))
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = { '^1SYSTEM', 'Verwendung: /uncuff [id]' }
            })
        end
        return
    end

    local ok, err = setPlayerUncuffed(targetId)
    if not ok then

        if source == 0 then
            print(('Uncuff fehlgeschlagen: %s'):format(err))
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = { '^1SYSTEM', ('Uncuff fehlgeschlagen: %s'):format(err) }
            })
        end
        return
    end

    if source == 0 then
        print(('Spieler %s wurde entfesselt.'):format(targetId))
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { '^2SYSTEM', ('Spieler %s wurde entfesselt.'):format(targetId) }
        })
    end
end, false)

RegisterCommand('uncuffall', function(source)

    local count = 0

    for _, playerId in ipairs(GetPlayers()) do
        local ok = setPlayerUncuffed(playerId)
        if ok then
            count = count + 1
        end
    end

    if source == 0 then
        print(('%s Spieler wurden entfesselt.'):format(count))
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = { '^2SYSTEM', ('%s Spieler wurden entfesselt.'):format(count) }
        })
    end
end, false)