if not RxBridge.NDCore.IsEnabled() then return end

NDCore = NDCore or {}
NDCore.character = {}

RegisterNetEvent('RXCore:Client:OnPlayerLoaded', function()
    NDCore.character = RxBridge.NDCore.ToCharacter(RXCore.PlayerData)
end)

RegisterNetEvent('RXCore:Client:OnPlayerUnload', function()
    NDCore.character = {}
end)

RegisterNetEvent('RXCore:Player:SetPlayerData', function(val)
    RXCore.PlayerData = val
    NDCore.character = RxBridge.NDCore.ToCharacter(val)
end)
