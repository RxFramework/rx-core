--- Shared GetCoreObject implementation for bridge scripts (do not re-export via exports['rx-core']).
RxBridge = RxBridge or {}

function RxBridge.GetCoreObject(filters)
    if not filters then return RXCore end
    local results = {}
    for i = 1, #filters do
        local key = filters[i]
        if RXCore[key] then
            results[key] = RXCore[key]
        end
    end
    return results
end
