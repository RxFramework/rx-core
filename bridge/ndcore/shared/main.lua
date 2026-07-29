RxBridge = RxBridge or {}
RxBridge.NDCore = RxBridge.NDCore or {}

RxBridge.NDCore.Enabled = GetConvar('rx:bridge:ndcore', 'false') == 'true'

function RxBridge.NDCore.IsEnabled()
    return RxBridge.NDCore.Enabled
end
