if not RxBridge.QBox.IsEnabled() then return end

QBX = {
    Players = RXCore.Players,
    Shared = {
        Items = RXShared.Items,
        Jobs = RXShared.Jobs,
        Gangs = RXShared.Gangs,
        Vehicles = RXShared.Vehicles,
        Weapons = RXShared.Weapons,
    },
    Config = RXConfig,
    Functions = RXCore.Functions,
    Player_Buckets = RXCore.Player_Buckets,
    Entity_Buckets = RXCore.Entity_Buckets,
    UsableItems = RXCore.UsableItems,
}

local function syncQbxState()
    QBX.Players = RXCore.Players
    QBX.Player_Buckets = RXCore.Player_Buckets
    QBX.Entity_Buckets = RXCore.Entity_Buckets
    QBX.UsableItems = RXCore.UsableItems
    QBX.Shared.Jobs = RXShared.Jobs
    QBX.Shared.Gangs = RXShared.Gangs
    QBX.Shared.Items = RXShared.Items
    QBX.Shared.Vehicles = RXShared.Vehicles
end

AddEventHandler('RXCore:Server:PlayerLoaded', syncQbxState)
AddEventHandler('RXCore:Server:OnPlayerUnload', syncQbxState)
AddEventHandler('RXCore:Server:UpdateObject', syncQbxState)
