if not RxBridge.ESX.IsEnabled() then return end

ESX = {
    Players = {},
    Jobs = RXShared.Jobs,
    Items = RXShared.Items,
}

function ESX.GetPlayerFromId(source)
    local player = RXCore.Functions.GetPlayer(source)
    if not player then return nil end
    return RxBridge.ESX.WrapPlayer(player)
end

function ESX.GetPlayerFromIdentifier(identifier)
    local player = RXCore.Functions.GetPlayerByLicense(identifier)
    if not player then
        player = RXCore.Functions.GetPlayerByCitizenId(identifier)
    end
    if not player then return nil end
    return RxBridge.ESX.WrapPlayer(player)
end

function ESX.GetPlayers()
    local players = {}
    for src in pairs(RXCore.Players) do
        players[#players + 1] = src
    end
    return players
end

function ESX.RegisterServerCallback(name, cb)
    RXCore.Functions.CreateCallback(name, cb)
end

function ESX.TriggerServerCallback(name, source, cb, ...)
    RXCore.Functions.TriggerCallback(name, source, cb, ...)
end

local function getSharedObject()
    return ESX
end

exports('getSharedObject', getSharedObject)

AddEventHandler('esx:getSharedObject', function(cb)
    cb(ESX)
end)

AddEventHandler('RXCore:Server:PlayerLoaded', function(Player)
    if not Player or not Player.PlayerData or not Player.PlayerData.source then return end
    local src = Player.PlayerData.source
    local xPlayer = RxBridge.ESX.WrapPlayer(Player)
    ESX.Players[src] = xPlayer
    TriggerEvent('esx:playerLoaded', src, xPlayer)
end)

AddEventHandler('RXCore:Server:OnPlayerUnload', function(source)
    ESX.Players[source] = nil
end)
