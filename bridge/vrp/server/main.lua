if not RxBridge.VRP.IsEnabled() then return end

vRP = vRP or {}
vRP.users = {}

local function getUserId(source)
    local player = RXCore.Functions.GetPlayer(source)
    if not player then return nil end
    return player.PlayerData.citizenid
end

local function getUserSource(userId)
    local player = RXCore.Functions.GetPlayerByCitizenId(userId)
    if player and player.PlayerData then
        return player.PlayerData.source
    end
    return nil
end

function vRP.getUserId(source)
    return getUserId(source)
end

function vRP.getUserSource(userId)
    return getUserSource(userId)
end

function vRP.getUserData(userId)
    local player = RXCore.Functions.GetPlayerByCitizenId(userId)
    if not player then return nil end
    return RxBridge.VRP.ToUserData(player.PlayerData)
end

exports('getUserId', getUserId)
exports('getUserSource', getUserSource)
exports('getUserData', vRP.getUserData)

AddEventHandler('RXCore:Server:PlayerLoaded', function(Player)
    if not Player or not Player.PlayerData or not Player.PlayerData.source then return end
    local src = Player.PlayerData.source
    local userId = Player.PlayerData.citizenid
    vRP.users[userId] = src
    TriggerEvent('vRP:playerJoin', userId, src, RxBridge.VRP.ToUserData(Player.PlayerData))
end)

AddEventHandler('RXCore:Server:OnPlayerUnload', function(source)
    local userId = getUserId(source)
    if userId then
        vRP.users[userId] = nil
        TriggerEvent('vRP:playerLeave', userId, source)
    end
end)
