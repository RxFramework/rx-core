if not RxBridge.ESX.IsEnabled() then return end

local forwarding = false

for rxEvent, _ in pairs(RxBridge.ESX.EventMap) do
    if RxBridge.NetForward.IsServerRxEvent(rxEvent) then
        AddEventHandler(rxEvent, function(...)
            if forwarding then return end
            forwarding = true
            RxBridge.ESX.ForwardEvent(rxEvent, ...)
            forwarding = false
        end)
    end
end

AddEventHandler('RXCore:Server:OnMoneyChange', function(source, moneyType, amount, action, reason)
    local player = RXCore.Functions.GetPlayer(source)
    if not player then return end
    local account = moneyType == 'cash' and 'money' or moneyType
    TriggerEvent('esx:setAccountMoney', source, account, player.PlayerData.money[moneyType] or 0, action)
end)
