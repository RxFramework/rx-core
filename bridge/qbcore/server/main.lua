if not RxBridge.QBCore.IsEnabled() then return end

QBCore = RXCore
QBShared = RXShared
QBConfig = RXConfig

--- GetCoreObject is registered once in server/main.lua (avoid export overwrite loop).
