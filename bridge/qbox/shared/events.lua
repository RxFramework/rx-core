RxBridge = RxBridge or {}
RxBridge.QBox = RxBridge.QBox or {}

--- RXCore -> legacy Qbox / QBCore events (job/gang handled in client/server events.lua)
RxBridge.QBox.EventMap = {
    ['RXCore:Client:OnPlayerLoaded'] = 'QBCore:Client:OnPlayerLoaded',
    ['RXCore:Client:OnPlayerUnload'] = 'QBCore:Client:OnPlayerUnload',
    ['RXCore:Player:SetPlayerData'] = 'QBCore:Player:SetPlayerData',
    ['RXCore:Notify'] = 'QBCore:Notify',
    ['RXCore:Server:OnPlayerUnload'] = 'QBCore:Server:OnPlayerUnload',
}

function RxBridge.QBox.ForwardEvent(eventName, ...)
    local legacy = RxBridge.QBox.EventMap[eventName]
    if legacy then
        TriggerEvent(legacy, ...)
    end
end

--- Legacy client events are forwarded locally on the client (see client/events.lua).
function RxBridge.QBox.ForwardClientEvent() end
