if not RxBridge.NDCore.IsEnabled() then return end

NDCore = NDCore or {}

function NDCore.getPlayer(source)
    local player = RXCore.Functions.GetPlayer(source)
    if not player then return nil end
    return RxBridge.NDCore.ToCharacter(player.PlayerData, player)
end

function NDCore.getPlayers()
    local characters = {}
    for src, player in pairs(RXCore.Players) do
        characters[src] = RxBridge.NDCore.ToCharacter(player.PlayerData, player)
    end
    return characters
end

exports('getPlayer', NDCore.getPlayer)
exports('getPlayers', NDCore.getPlayers)
