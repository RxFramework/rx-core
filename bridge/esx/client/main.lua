if not RxBridge.ESX.IsEnabled() then return end

ESX = {
    PlayerData = {},
    PlayerLoaded = false,
}

function ESX.GetPlayerData()
    return ESX.PlayerData
end

function ESX.IsPlayerLoaded()
    return ESX.PlayerLoaded
end

function ESX.ShowNotification(message, notifyType, length)
    RXCore.Functions.Notify(message, notifyType or 'primary', length or 5000)
end

function ESX.ShowHelpNotification(message)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType)
    RXCore.Functions.Notify(msg, 'primary', 5000)
end

function ESX.TriggerServerCallback(name, cb, ...)
    RXCore.Functions.TriggerCallback(name, cb, ...)
end

local function getSharedObject()
    return ESX
end

exports('getSharedObject', getSharedObject)

AddEventHandler('esx:getSharedObject', function(cb)
    cb(ESX)
end)

RegisterNetEvent('RXCore:Client:OnPlayerLoaded', function()
    ESX.PlayerData = RxBridge.ESX.ToEsxPlayerData(RXCore.PlayerData)
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('RXCore:Client:OnPlayerUnload', function()
    ESX.PlayerData = {}
    ESX.PlayerLoaded = false
end)

RegisterNetEvent('RXCore:Player:SetPlayerData', function(val)
    RXCore.PlayerData = val
    ESX.PlayerData = RxBridge.ESX.ToEsxPlayerData(val)
end)

RegisterNetEvent('RXCore:Client:OnJobUpdate', function(job)
    ESX.PlayerData.job = RxBridge.ESX.ToEsxJob(job)
end)

RegisterNetEvent('RXCore:Client:OnMoneyChange', function(moneyType, amount, action, reason)
    ESX.PlayerData.accounts = RxBridge.ESX.ToEsxAccounts(RXCore.PlayerData.money)
    local account = moneyType == 'cash' and 'money' or moneyType
    TriggerEvent('esx:setAccountMoney', { name = account, money = RXCore.PlayerData.money[moneyType] or 0 })
end)
