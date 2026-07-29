RxBridge = RxBridge or {}
RxBridge.ESX = RxBridge.ESX or {}

RxBridge.ESX.Enabled = GetConvar('rx:bridge:esx', 'false') == 'true'

function RxBridge.ESX.IsEnabled()
    return RxBridge.ESX.Enabled
end
