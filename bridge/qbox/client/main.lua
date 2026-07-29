if not RxBridge.QBox.IsEnabled() then return end

--- Qbox global (matches qbx_core layout used by JG scripts, etc.)
QBX = {
    PlayerData = RXCore.PlayerData,
    Shared = {
        Items = RXShared.Items,
        Jobs = RXShared.Jobs,
        Gangs = RXShared.Gangs,
        Vehicles = RXShared.Vehicles,
        Weapons = RXShared.Weapons,
    },
    Config = RXConfig,
    Functions = RXCore.Functions,
}

RegisterNetEvent('RXCore:Client:OnPlayerLoaded', function()
    QBX.PlayerData = RXCore.PlayerData
end)

RegisterNetEvent('RXCore:Client:OnPlayerUnload', function()
    QBX.PlayerData = {}
end)

RegisterNetEvent('RXCore:Player:SetPlayerData', function(val)
    RXCore.PlayerData = val
    QBX.PlayerData = val
end)
