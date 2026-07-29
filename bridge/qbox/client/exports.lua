if not RxBridge.QBox.IsEnabled() then return end

exports('GetPlayerData', function()
    return RXCore.Functions.GetPlayerData()
end)

exports('Notify', function(text, texttype, length, icon)
    RXCore.Functions.Notify(text, texttype, length, icon)
end)

exports('GetJobs', function()
    return RXShared.Jobs
end)

exports('GetGangs', function()
    return RXShared.Gangs
end)

exports('GetVehiclesByName', function()
    return RxBridge.QBox.GetVehiclesByName()
end)

exports('GetVehiclesByHash', function()
    return RxBridge.QBox.GetVehiclesByHash()
end)

exports('HasItem', function(items, amount)
    if GetResourceState('rx-inventory') == 'started' then
        return exports['rx-inventory']:HasItem(items, amount)
    end
    return RXCore.Functions.HasItem(items, amount)
end)

exports('GetSharedItems', function()
    return RXShared.Items
end)

exports('GetSharedVehicles', function()
    return RXShared.Vehicles
end)

exports('GetSharedJobs', function()
    return RXShared.Jobs
end)

exports('GetSharedGangs', function()
    return RXShared.Gangs
end)

--- Callbacks (legacy QBCore/Qbox style)
exports('TriggerCallback', function(name, cb, ...)
    RXCore.Functions.TriggerCallback(name, cb, ...)
end)
