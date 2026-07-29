---@class RxQBCoreBridgeConfig
RxBridge = RxBridge or {}
RxBridge.QBCore = RxBridge.QBCore or {}

RxBridge.QBCore.Enabled = GetConvar('rx:bridge:qbcore', 'true') == 'true'

function RxBridge.QBCore.IsEnabled()
    return RxBridge.QBCore.Enabled
end
