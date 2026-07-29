if not RxBridge.QBCore.IsEnabled() then return end

local forwarding = false

for rxEvent, _ in pairs(RxBridge.QBCore.EventMap) do
    if RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(rxEvent, function(...)
            if forwarding then return end
            forwarding = true
            RxBridge.QBCore.ForwardEvent(rxEvent, ...)
            forwarding = false
        end)
    end
end

AddEventHandler('RXCore:Server:PlayerLoaded', function(Player)
    if not Player or not Player.PlayerData then return end
    TriggerEvent('QBCore:Server:OnPlayerLoaded', Player)
end)

RegisterNetEvent('QBCore:CallCommand', function(command, args)
    local src = source
    local player = RXCore.Functions.GetPlayer(src)
    if not player then return end
    if IsPlayerAceAllowed(src --[[@as string]], ('command.%s'):format(command)) then
        local commandString = command
        for _, value in pairs(args or {}) do
            commandString = ('%s %s'):format(commandString, value)
        end
        RxBridge.NetForward.ToClient(src, 'QBCore:Command:CallCommand', commandString)
    end
end)
