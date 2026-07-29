RxBridge = RxBridge or {}
RxBridge.NDCore = RxBridge.NDCore or {}

--- RXCore -> ND Framework events
RxBridge.NDCore.EventMap = {
    ['RXCore:Client:OnPlayerLoaded'] = 'ND:characterLoaded',
    ['RXCore:Client:OnPlayerUnload'] = 'ND:characterUnloaded',
    ['RXCore:Client:OnJobUpdate'] = 'ND:updateCharacter',
    ['RXCore:Client:OnMoneyChange'] = 'ND:updateMoney',
    ['RXCore:Server:OnPlayerUnload'] = 'ND:characterUnloaded',
    ['RXCore:Server:OnJobUpdate'] = 'ND:updateCharacter',
    ['RXCore:Server:OnMoneyChange'] = 'ND:moneyChange',
}

function RxBridge.NDCore.ForwardEvent(eventName, ...)
    local legacy = RxBridge.NDCore.EventMap[eventName]
    if legacy then
        TriggerEvent(legacy, ...)
    end
end

--- Legacy client events are forwarded locally on the client (see client/events.lua).
function RxBridge.NDCore.ForwardClientEvent() end
