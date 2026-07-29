RxBridge = RxBridge or {}
RxBridge.QBCore = RxBridge.QBCore or {}

--- RXCore event name -> legacy QBCore event name
RxBridge.QBCore.EventMap = {
    -- Client
    ['RXCore:Client:OnPlayerLoaded'] = 'QBCore:Client:OnPlayerLoaded',
    ['RXCore:Client:OnPlayerUnload'] = 'QBCore:Client:OnPlayerUnload',
    ['RXCore:Client:PvpHasToggled'] = 'QBCore:Client:PvpHasToggled',
    ['RXCore:Client:OnJobUpdate'] = 'QBCore:Client:OnJobUpdate',
    ['RXCore:Client:OnGangUpdate'] = 'QBCore:Client:OnGangUpdate',
    ['RXCore:Client:OnMoneyChange'] = 'QBCore:Client:OnMoneyChange',
    ['RXCore:Client:SetDuty'] = 'QBCore:Client:SetDuty',
    ['RXCore:Client:UpdateObject'] = 'QBCore:Client:UpdateObject',
    ['RXCore:Client:OnSharedUpdate'] = 'QBCore:Client:OnSharedUpdate',
    ['RXCore:Client:OnSharedUpdateMultiple'] = 'QBCore:Client:OnSharedUpdateMultiple',
    ['RXCore:Client:SharedUpdate'] = 'QBCore:Client:SharedUpdate',
    ['RXCore:Client:UseItem'] = 'QBCore:Client:UseItem',
    ['RXCore:Client:TriggerClientCallback'] = 'QBCore:Client:TriggerClientCallback',
    ['RXCore:Client:TriggerCallback'] = 'QBCore:Client:TriggerCallback',
    ['RXCore:Client:VehicleInfo'] = 'QBCore:Client:VehicleInfo',
    ['RXCore:Client:AbortVehicleEntering'] = 'QBCore:Client:AbortVehicleEntering',
    ['RXCore:Player:SetPlayerData'] = 'QBCore:Player:SetPlayerData',
    ['RXCore:Player:UpdatePlayerData'] = 'QBCore:Player:UpdatePlayerData',
    ['RXCore:Notify'] = 'QBCore:Notify',
    ['RXCore:Command:TeleportToPlayer'] = 'QBCore:Command:TeleportToPlayer',
    ['RXCore:Command:TeleportToCoords'] = 'QBCore:Command:TeleportToCoords',
    ['RXCore:Command:GoToMarker'] = 'QBCore:Command:GoToMarker',
    ['RXCore:Command:SpawnVehicle'] = 'QBCore:Command:SpawnVehicle',
    ['RXCore:Command:DeleteVehicle'] = 'QBCore:Command:DeleteVehicle',
    ['RXCore:Command:ShowMe3D'] = 'QBCore:Command:ShowMe3D',
    -- Server
    ['RXCore:Server:OnPlayerUnload'] = 'QBCore:Server:OnPlayerUnload',
    ['RXCore:Server:PlayerLoaded'] = 'QBCore:Server:PlayerLoaded',
    ['RXCore:Server:PlayerDropped'] = 'QBCore:Server:PlayerDropped',
    ['RXCore:Server:OnJobUpdate'] = 'QBCore:Server:OnJobUpdate',
    ['RXCore:Server:OnGangUpdate'] = 'QBCore:Server:OnGangUpdate',
    ['RXCore:Server:OnMoneyChange'] = 'QBCore:Server:OnMoneyChange',
    ['RXCore:Server:SetDuty'] = 'QBCore:Server:SetDuty',
    ['RXCore:Server:UpdateObject'] = 'QBCore:Server:UpdateObject',
    ['RXCore:Server:CloseServer'] = 'QBCore:Server:CloseServer',
    ['RXCore:Server:OpenServer'] = 'QBCore:Server:OpenServer',
    ['RXCore:Server:TriggerClientCallback'] = 'QBCore:Server:TriggerClientCallback',
    ['RXCore:Server:TriggerCallback'] = 'QBCore:Server:TriggerCallback',
    ['RXCore:Server:UseItem'] = 'QBCore:Server:UseItem',
    ['RXCore:Server:RemoveItem'] = 'QBCore:Server:RemoveItem',
    ['RXCore:Server:AddItem'] = 'QBCore:Server:AddItem',
    ['RXCore:CallCommand'] = 'QBCore:CallCommand',
}

RxBridge.QBCore.ReverseEventMap = {}
for rxEvent, qbEvent in pairs(RxBridge.QBCore.EventMap) do
    RxBridge.QBCore.ReverseEventMap[qbEvent] = rxEvent
end

function RxBridge.QBCore.ForwardEvent(eventName, ...)
    local legacy = RxBridge.QBCore.EventMap[eventName]
    if legacy then
        TriggerEvent(legacy, ...)
    end
end

function RxBridge.QBCore.ForwardEventReverse(eventName, ...)
    local rxEvent = RxBridge.QBCore.ReverseEventMap[eventName]
    if rxEvent then
        TriggerEvent(rxEvent, ...)
    end
end
