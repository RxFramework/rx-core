if not RxBridge.VRP.IsEnabled() then return end

--- Minimal vRP client shim; full Proxy/Tunnel compat is not replicated here.
vRP = vRP or {}
vRP.user_data = {}

RegisterNetEvent('RXCore:Client:OnPlayerLoaded', function()
    vRP.user_data = RxBridge.VRP.ToUserData(RXCore.PlayerData)
end)

RegisterNetEvent('RXCore:Client:OnPlayerUnload', function()
    vRP.user_data = {}
end)

RegisterNetEvent('RXCore:Player:SetPlayerData', function(val)
    RXCore.PlayerData = val
    vRP.user_data = RxBridge.VRP.ToUserData(val)
end)

exports('getUserData', function()
    return vRP.user_data
end)
