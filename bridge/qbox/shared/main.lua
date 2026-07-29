RxBridge = RxBridge or {}
RxBridge.QBox = RxBridge.QBox or {}

RxBridge.QBox.Enabled = GetConvar('rx:bridge:qbox', 'true') == 'true'

function RxBridge.QBox.IsEnabled()
    return RxBridge.QBox.Enabled
end
