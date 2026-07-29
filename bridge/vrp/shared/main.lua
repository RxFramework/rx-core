RxBridge = RxBridge or {}
RxBridge.VRP = RxBridge.VRP or {}

RxBridge.VRP.Enabled = GetConvar('rx:bridge:vrp', 'false') == 'true'

function RxBridge.VRP.IsEnabled()
    return RxBridge.VRP.Enabled
end
