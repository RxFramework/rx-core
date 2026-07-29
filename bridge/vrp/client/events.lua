if not RxBridge.VRP.IsEnabled() then return end

local forwarding = false

local function forwardToLegacy(rxEvent, legacyEvent, ...)
    if forwarding then return end
    forwarding = true
    TriggerEvent(legacyEvent, ...)
    forwarding = false
end

for rxEvent, legacyEvent in pairs(RxBridge.VRP.EventMap) do
    if not RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(rxEvent, function(...)
            if rxEvent == 'RXCore:Client:OnPlayerLoaded' then
                TriggerEvent('vRP:playerSpawn', RxBridge.VRP.ToUserData(RXCore.PlayerData))
                return
            end
            if rxEvent == 'RXCore:Client:OnPlayerUnload' then
                TriggerEvent('vRP:playerLeave', vRP.user_data and vRP.user_data.citizenid)
                return
            end
            forwardToLegacy(rxEvent, legacyEvent, ...)
        end)
    end
end

for legacyEvent, rxEvent in pairs(RxBridge.VRP.ReverseEventMap) do
    if not RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(legacyEvent, function(...)
            if forwarding then return end
            forwarding = true
            RxBridge.VRP.ForwardEventReverse(legacyEvent, ...)
            forwarding = false
        end)
    end
end
