if not RxBridge.ESX.IsEnabled() then return end

local forwarding = false

local function forwardToLegacy(rxEvent, legacyEvent, ...)
    if forwarding then return end
    forwarding = true
    TriggerEvent(legacyEvent, ...)
    forwarding = false
end

for rxEvent, legacyEvent in pairs(RxBridge.ESX.EventMap) do
    if not RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(rxEvent, function(...)
            if rxEvent == 'RXCore:Client:OnPlayerLoaded' then
                local playerData = RxBridge.ESX.ToEsxPlayerData(RXCore.PlayerData)
                TriggerEvent('esx:playerLoaded', playerData, false, nil)
                return
            end
            forwardToLegacy(rxEvent, legacyEvent, ...)
        end)
    end
end

for legacyEvent, rxEvent in pairs(RxBridge.ESX.ReverseEventMap) do
    if not RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(legacyEvent, function(...)
            if forwarding then return end
            forwarding = true
            RxBridge.ESX.ForwardEventReverse(legacyEvent, ...)
            forwarding = false
        end)
    end
end
