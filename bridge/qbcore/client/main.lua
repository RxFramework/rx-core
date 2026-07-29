if not RxBridge.QBCore.IsEnabled() then return end

--- Legacy globals used by QBCore resources
QBCore = RXCore
QBShared = RXShared
QBConfig = RXConfig

--- GetCoreObject is registered once in client/main.lua (avoid export overwrite loop).
