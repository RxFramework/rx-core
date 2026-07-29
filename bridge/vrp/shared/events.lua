RxBridge = RxBridge or {}
RxBridge.VRP = RxBridge.VRP or {}

--- RXCore -> vRP client events only (server join/leave is handled in server/main.lua)
RxBridge.VRP.EventMap = {
    ['RXCore:Client:OnPlayerLoaded'] = 'vRP:playerSpawn',
    ['RXCore:Client:OnPlayerUnload'] = 'vRP:playerLeave',
}

--- Do not reverse-map vRP events back to RX on the server (wrong argument signatures).
RxBridge.VRP.ReverseEventMap = {}

function RxBridge.VRP.ForwardEvent(eventName, ...)
    local legacy = RxBridge.VRP.EventMap[eventName]
    if legacy then
        TriggerEvent(legacy, ...)
    end
end

function RxBridge.VRP.ForwardEventReverse() end

--- Legacy client events are forwarded locally on the client (see client/events.lua).
function RxBridge.VRP.ForwardClientEvent() end
