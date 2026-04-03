-- Early exit if module is disabled
if not Config or not Config.Modules or not Config.Modules.CombatRoll then
    return
end

CreateThread(function()
    while true do
        Wait(0)
        if IsPedArmed(PlayerPedId(), 6) and IsControlPressed(0, 25) then -- Aim
            DisableControlAction(0, 22, true) -- Space: Jump -> Combat Roll blocken
        end
    end
end)
