if not RxBridge.QBox.IsEnabled() then return end

local forwarding = false

for rxEvent, _ in pairs(RxBridge.QBox.EventMap) do
    if RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(rxEvent, function(...)
            if forwarding then return end
            forwarding = true
            RxBridge.QBox.ForwardEvent(rxEvent, ...)
            forwarding = false
        end)
    end
end

AddEventHandler('RXCore:Server:PlayerLoaded', function(Player)
    if not Player or not Player.PlayerData or not Player.PlayerData.source then return end
    TriggerEvent('QBCore:Server:OnPlayerLoaded', Player)
end)

AddEventHandler('RXCore:Server:OnJobUpdate', function(_, job)
    TriggerEvent('qbx_core:server:onJobUpdate', job.name, job)
end)

AddEventHandler('RXCore:Server:OnGangUpdate', function(_, gang)
    TriggerEvent('qbx_core:server:onGangUpdate', gang.name, gang)
end)

AddEventHandler('RXCore:Client:OnSharedUpdate', function(_, tableName)
    if tableName == 'Vehicles' then
        RxBridge.QBox.InvalidateVehicleCache()
    end
end)
