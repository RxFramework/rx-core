if not RxBridge.QBCore.IsEnabled() then return end

local forwarding = false

local function forwardToLegacy(rxEvent, legacyEvent, ...)
    if forwarding then return end
    forwarding = true
    TriggerEvent(legacyEvent, ...)
    forwarding = false
end

for rxEvent, legacyEvent in pairs(RxBridge.QBCore.EventMap) do
    if not RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(rxEvent, function(...)
            forwardToLegacy(rxEvent, legacyEvent, ...)
        end)
    end
end

for legacyEvent, rxEvent in pairs(RxBridge.QBCore.ReverseEventMap) do
    if not RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(legacyEvent, function(...)
            if forwarding then return end
            forwarding = true
            RxBridge.QBCore.ForwardEventReverse(legacyEvent, ...)
            forwarding = false
        end)
    end
end

RegisterNetEvent('QBCore:Command:CallCommand', function(command)
    ExecuteCommand(command)
end)
