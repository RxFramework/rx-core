RxBridge = RxBridge or {}
RxBridge.QBox = RxBridge.QBox or {}

local vehiclesByHash

function RxBridge.QBox.GetVehiclesByName()
    return RXShared.Vehicles
end

function RxBridge.QBox.GetVehiclesByHash()
    if vehiclesByHash then return vehiclesByHash end

    vehiclesByHash = {}
    for model, data in pairs(RXShared.Vehicles) do
        vehiclesByHash[model] = data
        if type(model) == 'string' then
            vehiclesByHash[joaat(model)] = data
        end
    end

    return vehiclesByHash
end

function RxBridge.QBox.InvalidateVehicleCache()
    vehiclesByHash = nil
end
