if not RxBridge.QBox.IsEnabled() then return end

local function coreExport(name)
    return function(...)
        return exports['rx-core'][name](...)
    end
end

--- Player lookups
exports('GetPlayer', function(source)
    return RXCore.Functions.GetPlayer(source)
end)

exports('GetPlayers', function()
    return RXCore.Functions.GetPlayers()
end)

exports('GetQBPlayers', function()
    return RXCore.Functions.GetQBPlayers()
end)

exports('GetPlayerByCitizenId', function(citizenid)
    return RXCore.Functions.GetPlayerByCitizenId(citizenid)
end)

exports('GetOfflinePlayerByCitizenId', function(citizenid)
    return RXCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
end)

exports('GetPlayerByLicense', function(license)
    return RXCore.Functions.GetPlayerByLicense(license)
end)

exports('GetPlayerByPhone', function(number)
    return RXCore.Functions.GetPlayerByPhone(number)
end)

exports('GetPlayerByAccount', function(account)
    return RXCore.Functions.GetPlayerByAccount(account)
end)

exports('GetPlayerByCharInfo', function(property, value)
    return RXCore.Functions.GetPlayerByCharInfo(property, value)
end)

exports('GetPlayersByJob', function(job, checkOnDuty)
    return RXCore.Functions.GetPlayersByJob(job, checkOnDuty)
end)

exports('GetPlayersOnDuty', function(job)
    return RXCore.Functions.GetPlayersOnDuty(job)
end)

exports('GetDutyCount', function(job)
    return RXCore.Functions.GetDutyCount(job)
end)

exports('GetSource', function(identifier)
    return RXCore.Functions.GetSource(identifier)
end)

exports('GetIdentifier', function(source, idtype)
    return RXCore.Functions.GetIdentifier(source, idtype)
end)

--- Shared data
exports('GetJobs', function()
    return RXShared.Jobs
end)

exports('GetGangs', function()
    return RXShared.Gangs
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

exports('GetVehiclesByName', function()
    return RxBridge.QBox.GetVehiclesByName()
end)

exports('GetVehiclesByHash', function()
    return RxBridge.QBox.GetVehiclesByHash()
end)

--- GetCoreObject is registered once in server/main.lua (avoid export overwrite loop).

exports('GetCoreVersion', coreExport('GetCoreVersion'))

--- Items & jobs (re-export rx-core exports)
exports('CreateUseableItem', function(item, data)
    RXCore.Functions.CreateUseableItem(item, data)
end)

exports('HasItem', function(source, items, amount)
    if GetResourceState('rx-inventory') == 'started' then
        return exports['rx-inventory']:HasItem(source, items, amount)
    end
    return RXCore.Functions.HasItem(source, items, amount)
end)

exports('Notify', function(source, text, texttype, length, icon)
    TriggerClientEvent('RXCore:Notify', source, text, texttype, length, icon)
end)

exports('AddJob', coreExport('AddJob'))
exports('RemoveJob', coreExport('RemoveJob'))
exports('UpdateJob', coreExport('UpdateJob'))
exports('AddJobs', coreExport('AddJobs'))
exports('AddItem', coreExport('AddItem'))
exports('UpdateItem', coreExport('UpdateItem'))
exports('AddItems', coreExport('AddItems'))
exports('RemoveItem', coreExport('RemoveItem'))
exports('AddGang', coreExport('AddGang'))
exports('RemoveGang', coreExport('RemoveGang'))
exports('UpdateGang', coreExport('UpdateGang'))
exports('AddGangs', coreExport('AddGangs'))

--- Login helpers (Qbox character scripts)
exports('Login', function(source, citizenid, newData)
    return RXCore.Player.Login(source, citizenid, newData)
end)

exports('Logout', function(source)
    RXCore.Player.Logout(source)
end)
