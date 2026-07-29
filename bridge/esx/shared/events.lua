RxBridge = RxBridge or {}
RxBridge.ESX = RxBridge.ESX or {}

--- RXCore event name -> legacy ESX event name
RxBridge.ESX.EventMap = {
    ['RXCore:Client:OnPlayerLoaded'] = 'esx:playerLoaded',
    ['RXCore:Client:OnPlayerUnload'] = 'esx:onPlayerLogout',
    ['RXCore:Client:OnJobUpdate'] = 'esx:setJob',
    ['RXCore:Notify'] = 'esx:showNotification',
    ['RXCore:Server:OnPlayerUnload'] = 'esx:playerDropped',
    ['RXCore:Server:OnJobUpdate'] = 'esx:setJob',
}

RxBridge.ESX.ReverseEventMap = {}
for rxEvent, esxEvent in pairs(RxBridge.ESX.EventMap) do
    RxBridge.ESX.ReverseEventMap[esxEvent] = rxEvent
end

function RxBridge.ESX.ForwardEvent(eventName, ...)
    local legacy = RxBridge.ESX.EventMap[eventName]
    if legacy then
        TriggerEvent(legacy, ...)
    end
end

function RxBridge.ESX.ForwardEventReverse(eventName, ...)
    local rxEvent = RxBridge.ESX.ReverseEventMap[eventName]
    if rxEvent then
        TriggerEvent(rxEvent, ...)
    end
end

--- Legacy client events are forwarded locally on the client (see client/events.lua).
function RxBridge.ESX.ForwardClientEvent() end
