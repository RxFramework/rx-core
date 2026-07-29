if not RxBridge.QBox.IsEnabled() then return end

local forwarding = false

for rxEvent, _ in pairs(RxBridge.QBox.EventMap) do
    if not RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(rxEvent, function(...)
            if forwarding then return end
            forwarding = true
            RxBridge.QBox.ForwardEvent(rxEvent, ...)
            forwarding = false
        end)
    end
end

RegisterNetEvent('RXCore:Client:OnJobUpdate', function(job)
    if QBX.PlayerData then
        QBX.PlayerData.job = job
    end
    TriggerEvent('qbx_core:client:onJobUpdate', job.name, job)
end)

RegisterNetEvent('RXCore:Client:OnGangUpdate', function(gang)
    if QBX.PlayerData then
        QBX.PlayerData.gang = gang
    end
    TriggerEvent('qbx_core:client:onGangUpdate', gang.name, gang)
end)

RegisterNetEvent('RXCore:Client:OnSharedUpdate', function(tableName)
    if tableName == 'Vehicles' then
        RxBridge.QBox.InvalidateVehicleCache()
    end
    if tableName == 'Jobs' and QBX.Shared then
        QBX.Shared.Jobs = RXShared.Jobs
    end
    if tableName == 'Gangs' and QBX.Shared then
        QBX.Shared.Gangs = RXShared.Gangs
    end
end)
