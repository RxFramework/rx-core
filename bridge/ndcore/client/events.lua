if not RxBridge.NDCore.IsEnabled() then return end

local forwarding = false

for rxEvent, _ in pairs(RxBridge.NDCore.EventMap) do
    if not RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(rxEvent, function(...)
            if forwarding then return end
            forwarding = true
            RxBridge.NDCore.ForwardEvent(rxEvent, ...)
            forwarding = false
        end)
    end
end

AddEventHandler('RXCore:Client:OnPlayerLoaded', function()
    local character = RxBridge.NDCore.ToCharacter(RXCore.PlayerData)
    TriggerEvent('ND:characterLoaded', character)
    TriggerEvent('characterLoaded', character)
end)

AddEventHandler('RXCore:Client:OnPlayerUnload', function()
    local character = NDCore.character or {}
    TriggerEvent('ND:characterUnloaded', character)
end)

RegisterNetEvent('RXCore:Client:OnJobUpdate', function(job)
    if NDCore.character then
        NDCore.character.job = job.name
        NDCore.character.jobInfo = job
    end
    local character = RxBridge.NDCore.ToCharacter(RXCore.PlayerData)
    TriggerEvent('ND:updateCharacter', character)
end)

RegisterNetEvent('RXCore:Client:OnMoneyChange', function()
    local money = RXCore.PlayerData.money or {}
    TriggerEvent('ND:updateMoney', money.cash or 0, money.bank or 0)
end)
