local function resetPlayerFromCuff()
    local ped = PlayerPedId()
    local playerId = PlayerId()

    ClearPedTasksImmediately(ped)
    ClearPedSecondaryTask(ped)

    SetEnableHandcuffs(ped, false)
    DisablePlayerFiring(playerId, false)

    ResetPedMovementClipset(ped, 0.0)
    ResetPedStrafeClipset(ped)
    ResetPedWeaponMovementClipset(ped)

    LocalPlayer.state:set('isCuffed', false, true)
    LocalPlayer.state:set('cuffType', false, true)
    LocalPlayer.state:set('draggedBy', 0, true)

end

RegisterNetEvent('p_policejob:ForceUncuff', function()

    resetPlayerFromCuff()
    CreateThread(function()
        for i = 1, 5 do
            Wait(200)
            resetPlayerFromCuff()
        end
    end)
end)