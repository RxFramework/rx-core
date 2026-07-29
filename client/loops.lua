CreateThread(function()
    while true do
        local sleep = 0
        if LocalPlayer.state.isLoggedIn then
            sleep = (1000 * 60) * RXCore.Config.UpdateInterval
            TriggerServerEvent('RXCore:UpdatePlayer')
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            if (RXCore.PlayerData.metadata['hunger'] <= 0 or RXCore.PlayerData.metadata['thirst'] <= 0) and not (RXCore.PlayerData.metadata['isdead'] or RXCore.PlayerData.metadata['inlaststand']) then
                local ped = PlayerPedId()
                local currentHealth = GetEntityHealth(ped)
                local decreaseThreshold = math.random(5, 10)
                SetEntityHealth(ped, currentHealth - decreaseThreshold)
            end
        end
        Wait(RXCore.Config.StatusInterval)
    end
end)
