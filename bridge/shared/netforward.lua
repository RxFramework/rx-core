--- Safe server -> client forwarding for legacy local-only events.
--- Legacy bridge events must NOT use TriggerClientEvent directly; use this helper instead.
RxBridge = RxBridge or {}
RxBridge.NetForward = RxBridge.NetForward or {}

local INTERNAL_EVENT = 'rx-bridge:client:localEvent'

function RxBridge.NetForward.IsServerRxEvent(eventName)
    return type(eventName) == 'string' and (
        eventName:find('^RXCore:Server') ~= nil
        or eventName == 'RXCore:CallCommand'
    )
end

if IsDuplicityVersion() then
    function RxBridge.NetForward.ToClient(source, legacyEvent, ...)
        if type(legacyEvent) ~= 'string' or legacyEvent == '' then return end
        TriggerClientEvent(INTERNAL_EVENT, source, legacyEvent, ...)
    end
else
    RegisterNetEvent(INTERNAL_EVENT, function(legacyEvent, ...)
        if type(legacyEvent) ~= 'string' or legacyEvent == '' then return end
        TriggerEvent(legacyEvent, ...)
    end)
end
