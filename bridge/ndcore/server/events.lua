if not RxBridge.NDCore.IsEnabled() then return end

local forwarding = false

for rxEvent, _ in pairs(RxBridge.NDCore.EventMap) do
    if RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(rxEvent, function(...)
            if forwarding then return end
            forwarding = true
            RxBridge.NDCore.ForwardEvent(rxEvent, ...)
            forwarding = false
        end)
    end
end

AddEventHandler('RXCore:Server:PlayerLoaded', function(Player)
    if not Player or not Player.PlayerData then return end
    local character = RxBridge.NDCore.ToCharacter(Player.PlayerData, Player)
    TriggerEvent('ND:characterLoaded', character)
end)

AddEventHandler('RXCore:Server:OnPlayerUnload', function(source)
    local player = RXCore.Functions.GetPlayer(source)
    local character = player and RxBridge.NDCore.ToCharacter(player.PlayerData, player) or { source = source }
    TriggerEvent('ND:characterUnloaded', source, character)
end)

AddEventHandler('RXCore:Server:OnJobUpdate', function(src, job)
    local player = RXCore.Functions.GetPlayer(src)
    if not player then return end
    local character = RxBridge.NDCore.ToCharacter(player.PlayerData, player)
    TriggerEvent('ND:updateCharacter', character)
end)

AddEventHandler('RXCore:Server:OnMoneyChange', function(source, moneyType, amount, action, reason)
    local player = RXCore.Functions.GetPlayer(source)
    if not player then return end
    TriggerEvent('ND:moneyChange', source, moneyType, amount, action, reason)
end)
