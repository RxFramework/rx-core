RXCore.Players = {}
RXCore.Player = {}

-- On player login get their data or set defaults
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

local resourceName = GetCurrentResourceName()
function RXCore.Player.Login(source, citizenid, newData)
    if source and source ~= '' then
        if citizenid then
            local license = RXCore.Functions.GetIdentifier(source, 'license')
            local PlayerData = MySQL.prepare.await('SELECT * FROM players where citizenid = ?', { citizenid })
            if PlayerData and license == PlayerData.license then
                PlayerData.money = json.decode(PlayerData.money)
                PlayerData.job = json.decode(PlayerData.job)
                PlayerData.gang = json.decode(PlayerData.gang)
                PlayerData.position = json.decode(PlayerData.position)
                PlayerData.metadata = json.decode(PlayerData.metadata)
                PlayerData.charinfo = json.decode(PlayerData.charinfo)
                RXCore.Player.CheckPlayerData(source, PlayerData)
            else
                DropPlayer(source, Lang:t('info.exploit_dropped'))
                TriggerEvent('rx-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Joining Exploit', false)
            end
        else
            RXCore.Player.CheckPlayerData(source, newData)
        end
        return true
    else
        RXCore.ShowError(resourceName, 'ERROR RXCORE.PLAYER.LOGIN - NO SOURCE GIVEN!')
        return false
    end
end

function RXCore.Player.GetOfflinePlayer(citizenid)
    if citizenid then
        local PlayerData = MySQL.prepare.await('SELECT * FROM players where citizenid = ?', { citizenid })
        if PlayerData then
            PlayerData.money = json.decode(PlayerData.money)
            PlayerData.job = json.decode(PlayerData.job)
            PlayerData.gang = json.decode(PlayerData.gang)
            PlayerData.position = json.decode(PlayerData.position)
            PlayerData.metadata = json.decode(PlayerData.metadata)
            PlayerData.charinfo = json.decode(PlayerData.charinfo)
            return RXCore.Player.CheckPlayerData(nil, PlayerData)
        end
    end
    return nil
end

function RXCore.Player.GetPlayerByLicense(license)
    if license then
        local source = RXCore.Functions.GetSource(license)
        if source > 0 then
            return RXCore.Players[source]
        else
            return RXCore.Player.GetOfflinePlayerByLicense(license)
        end
    end
    return nil
end

function RXCore.Player.GetOfflinePlayerByLicense(license)
    if license then
        local PlayerData = MySQL.prepare.await('SELECT * FROM players where license = ?', { license })
        if PlayerData then
            PlayerData.money = json.decode(PlayerData.money)
            PlayerData.job = json.decode(PlayerData.job)
            PlayerData.gang = json.decode(PlayerData.gang)
            PlayerData.position = json.decode(PlayerData.position)
            PlayerData.metadata = json.decode(PlayerData.metadata)
            PlayerData.charinfo = json.decode(PlayerData.charinfo)
            return RXCore.Player.CheckPlayerData(nil, PlayerData)
        end
    end
    return nil
end

local function applyDefaults(playerData, defaults)
    for key, value in pairs(defaults) do
        if type(value) == 'function' then
            playerData[key] = playerData[key] or value()
        elseif type(value) == 'table' then
            playerData[key] = playerData[key] or {}
            applyDefaults(playerData[key], value)
        else
            playerData[key] = playerData[key] or value
        end
    end
end

function RXCore.Player.CheckPlayerData(source, PlayerData)
    PlayerData = PlayerData or {}
    local Offline = not source

    if source then
        PlayerData.source = source
        PlayerData.license = PlayerData.license or RXCore.Functions.GetIdentifier(source, 'license')
        PlayerData.name = GetPlayerName(source)
    end

    local validatedJob = false
    if PlayerData.job and PlayerData.job.name ~= nil and PlayerData.job.grade and PlayerData.job.grade.level ~= nil then
        local jobInfo = RXCore.Shared.Jobs[PlayerData.job.name]

        if jobInfo then
            local jobGradeInfo = jobInfo.grades[tostring(PlayerData.job.grade.level)]
            if jobGradeInfo then
                PlayerData.job.label = jobInfo.label
                PlayerData.job.grade.name = jobGradeInfo.name
                PlayerData.job.payment = jobGradeInfo.payment
                PlayerData.job.grade.isboss = jobGradeInfo.isboss or false
                PlayerData.job.isboss = jobGradeInfo.isboss or false
                validatedJob = true
            end
        end
    end

    if validatedJob == false then
        -- set to nil, as the default job (unemployed) will be added by `applyDefaults`
        PlayerData.job = nil
    end

    local validatedGang = false
    if PlayerData.gang and PlayerData.gang.name ~= nil and PlayerData.gang.grade and PlayerData.gang.grade.level ~= nil then
        local gangInfo = RXCore.Shared.Gangs[PlayerData.gang.name]

        if gangInfo then
            local gangGradeInfo = gangInfo.grades[tostring(PlayerData.gang.grade.level)]
            if gangGradeInfo then
                PlayerData.gang.label = gangInfo.label
                PlayerData.gang.grade.name = gangGradeInfo.name
                PlayerData.gang.payment = gangGradeInfo.payment
                PlayerData.gang.grade.isboss = gangGradeInfo.isboss or false
                PlayerData.gang.isboss = gangGradeInfo.isboss or false
                validatedGang = true
            end
        end
    end

    if validatedGang == false then
        -- set to nil, as the default gang (unemployed) will be added by `applyDefaults`
        PlayerData.gang = nil
    end

    applyDefaults(PlayerData, RXCore.Config.Player.PlayerDefaults)
    if PlayerData.job and RXCore.Shared.ForceJobDefaultDutyAtLogin then
        local jobInfo = RXCore.Shared.Jobs[PlayerData.job.name]
        if jobInfo then
            PlayerData.job.onduty = jobInfo.defaultDuty
        end
    end

    if GetResourceState('rx-inventory') ~= 'missing' then
        PlayerData.items = exports['rx-inventory']:LoadInventory(PlayerData.source, PlayerData.citizenid)
    end

    return RXCore.Player.CreatePlayer(PlayerData, Offline)
end

-- On player logout

function RXCore.Player.Logout(source)
    TriggerClientEvent('RXCore:Client:OnPlayerUnload', source)
    TriggerEvent('RXCore:Server:OnPlayerUnload', source)
    TriggerClientEvent('RXCore:Player:UpdatePlayerData', source)
    Wait(200)
    RXCore.Players[source] = nil
end

-- Create a new character
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

function RXCore.Player.CreatePlayer(PlayerData, Offline)
    local self = {}
    self.Functions = {}
    self.PlayerData = PlayerData
    self.Offline = Offline

    function self.Functions.UpdatePlayerData()
        if self.Offline then return end
        TriggerEvent('RXCore:Player:SetPlayerData', self.PlayerData)
        TriggerClientEvent('RXCore:Player:SetPlayerData', self.PlayerData.source, self.PlayerData)
    end

    function self.Functions.SetJob(job, grade)
        job = job:lower()
        grade = grade or '0'
        if not RXCore.Shared.Jobs[job] then return false end
        self.PlayerData.job = {
            name = job,
            label = RXCore.Shared.Jobs[job].label,
            onduty = RXCore.Shared.Jobs[job].defaultDuty,
            type = RXCore.Shared.Jobs[job].type or 'none',
            grade = {
                name = 'No Grades',
                level = 0,
                payment = 30,
                isboss = false
            }
        }
        local gradeKey = tostring(grade)
        local jobGradeInfo = RXCore.Shared.Jobs[job].grades[gradeKey]
        if jobGradeInfo then
            self.PlayerData.job.grade.name = jobGradeInfo.name
            self.PlayerData.job.grade.level = tonumber(gradeKey)
            self.PlayerData.job.grade.payment = jobGradeInfo.payment
            self.PlayerData.job.grade.isboss = jobGradeInfo.isboss or false
            self.PlayerData.job.isboss = jobGradeInfo.isboss or false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('RXCore:Server:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
            TriggerClientEvent('RXCore:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        end

        return true
    end

    function self.Functions.SetGang(gang, grade)
        gang = gang:lower()
        grade = grade or '0'
        if not RXCore.Shared.Gangs[gang] then return false end
        self.PlayerData.gang = {
            name = gang,
            label = RXCore.Shared.Gangs[gang].label,
            grade = {
                name = 'No Grades',
                level = 0,
                isboss = false
            }
        }
        local gradeKey = tostring(grade)
        local gangGradeInfo = RXCore.Shared.Gangs[gang].grades[gradeKey]
        if gangGradeInfo then
            self.PlayerData.gang.grade.name = gangGradeInfo.name
            self.PlayerData.gang.grade.level = tonumber(gradeKey)
            self.PlayerData.gang.grade.isboss = gangGradeInfo.isboss or false
            self.PlayerData.gang.isboss = gangGradeInfo.isboss or false
        end

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('RXCore:Server:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
            TriggerClientEvent('RXCore:Client:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
        end

        return true
    end

    function self.Functions.Notify(text, type, length)
        TriggerClientEvent('RXCore:Notify', self.PlayerData.source, text, type, length)
    end

    function self.Functions.HasItem(items, amount)
        return RXCore.Functions.HasItem(self.PlayerData.source, items, amount)
    end

    function self.Functions.GetName()
        local charinfo = self.PlayerData.charinfo
        return charinfo.firstname .. ' ' .. charinfo.lastname
    end

    function self.Functions.SetJobDuty(onDuty)
        self.PlayerData.job.onduty = not not onDuty
        TriggerEvent('RXCore:Server:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        TriggerClientEvent('RXCore:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetPlayerData(key, val)
        if not key or type(key) ~= 'string' then return end
        self.PlayerData[key] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetMetaData(meta, val)
        if not meta or type(meta) ~= 'string' then return end
        if meta == 'hunger' or meta == 'thirst' then
            val = val > 100 and 100 or val
        end
        self.PlayerData.metadata[meta] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.GetMetaData(meta)
        if not meta or type(meta) ~= 'string' then return end
        return self.PlayerData.metadata[meta]
    end

    function self.Functions.AddRep(rep, amount)
        if not rep or not amount then return end
        local addAmount = tonumber(amount)
        local currentRep = self.PlayerData.metadata['rep'][rep] or 0
        self.PlayerData.metadata['rep'][rep] = currentRep + addAmount
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.RemoveRep(rep, amount)
        if not rep or not amount then return end
        local removeAmount = tonumber(amount)
        local currentRep = self.PlayerData.metadata['rep'][rep] or 0
        if currentRep - removeAmount < 0 then
            self.PlayerData.metadata['rep'][rep] = 0
        else
            self.PlayerData.metadata['rep'][rep] = currentRep - removeAmount
        end
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.GetRep(rep)
        if not rep then return end
        return self.PlayerData.metadata['rep'][rep] or 0
    end

    function self.Functions.AddMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return end
        if not self.PlayerData.money[moneytype] then return false end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('rx-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('rx-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, false)
            TriggerClientEvent('RXCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
            TriggerEvent('RXCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
        end

        return true
    end

    function self.Functions.RemoveMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return end
        if not self.PlayerData.money[moneytype] then return false end
        for _, mtype in pairs(RXCore.Config.Money.DontAllowMinus) do
            if mtype == moneytype then
                if (self.PlayerData.money[moneytype] - amount) < 0 then
                    return false
                end
            end
        end
        if self.PlayerData.money[moneytype] - amount < RXCore.Config.Money.MinusLimit then return false end
        self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            if amount > 100000 then
                TriggerEvent('rx-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
            else
                TriggerEvent('rx-log:server:CreateLog', 'playermoney', 'RemoveMoney', 'red', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            end
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, true)
            if moneytype == 'bank' then
                TriggerClientEvent('rx-phone:client:RemoveBankMoney', self.PlayerData.source, amount)
            end
            TriggerClientEvent('RXCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'remove', reason)
            TriggerEvent('RXCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'remove', reason)
        end

        return true
    end

    function self.Functions.SetMoney(moneytype, amount, reason)
        reason = reason or 'unknown'
        moneytype = moneytype:lower()
        amount = tonumber(amount)
        if amount < 0 then return false end
        if not self.PlayerData.money[moneytype] then return false end
        local difference = amount - self.PlayerData.money[moneytype]
        self.PlayerData.money[moneytype] = amount

        if not self.Offline then
            self.Functions.UpdatePlayerData()
            TriggerEvent('rx-log:server:CreateLog', 'playermoney', 'SetMoney', 'green', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') set, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
            TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, math.abs(difference), difference < 0)
            TriggerClientEvent('RXCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'set', reason)
            TriggerEvent('RXCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'set', reason)
        end

        return true
    end

    function self.Functions.GetMoney(moneytype)
        if not moneytype then return false end
        moneytype = moneytype:lower()
        return self.PlayerData.money[moneytype]
    end

    function self.Functions.Save()
        if self.Offline then
            RXCore.Player.SaveOffline(self.PlayerData)
        else
            RXCore.Player.Save(self.PlayerData.source)
        end
    end

    function self.Functions.Logout()
        if self.Offline then return end
        RXCore.Player.Logout(self.PlayerData.source)
    end

    function self.Functions.AddMethod(methodName, handler)
        self.Functions[methodName] = handler
    end

    function self.Functions.AddField(fieldName, data)
        self[fieldName] = data
    end

    if self.Offline then
        return self
    else
        RXCore.Players[self.PlayerData.source] = self
        RXCore.Player.Save(self.PlayerData.source)
        TriggerEvent('RXCore:Server:PlayerLoaded', self)
        self.Functions.UpdatePlayerData()
    end
end

-- Add a new function to the Functions table of the player class
-- Use-case:
--[[
    AddEventHandler('RXCore:Server:PlayerLoaded', function(Player)
        RXCore.Functions.AddPlayerMethod(Player.PlayerData.source, "functionName", function(oneArg, orMore)
            -- do something here
        end)
    end)
]]

function RXCore.Functions.AddPlayerMethod(ids, methodName, handler)
    local idType = type(ids)
    if idType == 'number' then
        if ids == -1 then
            for _, v in pairs(RXCore.Players) do
                v.Functions.AddMethod(methodName, handler)
            end
        else
            if not RXCore.Players[ids] then return end

            RXCore.Players[ids].Functions.AddMethod(methodName, handler)
        end
    elseif idType == 'table' and table.type(ids) == 'array' then
        for i = 1, #ids do
            RXCore.Functions.AddPlayerMethod(ids[i], methodName, handler)
        end
    end
end

-- Add a new field table of the player class
-- Use-case:
--[[
    AddEventHandler('RXCore:Server:PlayerLoaded', function(Player)
        RXCore.Functions.AddPlayerField(Player.PlayerData.source, "fieldName", "fieldData")
    end)
]]

function RXCore.Functions.AddPlayerField(ids, fieldName, data)
    local idType = type(ids)
    if idType == 'number' then
        if ids == -1 then
            for _, v in pairs(RXCore.Players) do
                v.Functions.AddField(fieldName, data)
            end
        else
            if not RXCore.Players[ids] then return end

            RXCore.Players[ids].Functions.AddField(fieldName, data)
        end
    elseif idType == 'table' and table.type(ids) == 'array' then
        for i = 1, #ids do
            RXCore.Functions.AddPlayerField(ids[i], fieldName, data)
        end
    end
end

-- Save player info to database (make sure citizenid is the primary key in your database)

function RXCore.Player.Save(source)
    local ped = GetPlayerPed(source)
    local pcoords = GetEntityCoords(ped)
    local PlayerData = RXCore.Players[source].PlayerData
    if PlayerData then
        MySQL.insert('INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata', {
            citizenid = PlayerData.citizenid,
            cid = tonumber(PlayerData.cid),
            license = PlayerData.license,
            name = PlayerData.name,
            money = json.encode(PlayerData.money),
            charinfo = json.encode(PlayerData.charinfo),
            job = json.encode(PlayerData.job),
            gang = json.encode(PlayerData.gang),
            position = json.encode(pcoords),
            metadata = json.encode(PlayerData.metadata)
        })
        if GetResourceState('rx-inventory') ~= 'missing' then exports['rx-inventory']:SaveInventory(source) end
        RXCore.ShowSuccess(resourceName, PlayerData.name .. ' PLAYER SAVED!')
    else
        RXCore.ShowError(resourceName, 'ERROR RXCORE.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
    end
end

function RXCore.Player.SaveOffline(PlayerData)
    if PlayerData then
        MySQL.insert('INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata', {
            citizenid = PlayerData.citizenid,
            cid = tonumber(PlayerData.cid),
            license = PlayerData.license,
            name = PlayerData.name,
            money = json.encode(PlayerData.money),
            charinfo = json.encode(PlayerData.charinfo),
            job = json.encode(PlayerData.job),
            gang = json.encode(PlayerData.gang),
            position = json.encode(PlayerData.position),
            metadata = json.encode(PlayerData.metadata)
        })
        if GetResourceState('rx-inventory') ~= 'missing' then exports['rx-inventory']:SaveInventory(PlayerData, true) end
        RXCore.ShowSuccess(resourceName, PlayerData.name .. ' OFFLINE PLAYER SAVED!')
    else
        RXCore.ShowError(resourceName, 'ERROR RXCORE.PLAYER.SAVEOFFLINE - PLAYERDATA IS EMPTY!')
    end
end

-- Delete character

local playertables = { -- Add tables as needed
    { table = 'players' },
    { table = 'apartments' },
    { table = 'bank_accounts' },
    { table = 'crypto_transactions' },
    { table = 'phone_invoices' },
    { table = 'phone_messages' },
    { table = 'playerskins' },
    { table = 'player_contacts' },
    { table = 'player_houses' },
    { table = 'player_mails' },
    { table = 'player_outfits' },
    { table = 'player_vehicles' }
}

function RXCore.Player.DeleteCharacter(source, citizenid)
    local license = RXCore.Functions.GetIdentifier(source, 'license')
    local result = MySQL.scalar.await('SELECT license FROM players where citizenid = ?', { citizenid })
    if license == result then
        local query = 'DELETE FROM %s WHERE citizenid = ?'
        local tableCount = #playertables
        local queries = table.create(tableCount, 0)

        for i = 1, tableCount do
            local v = playertables[i]
            queries[i] = { query = query:format(v.table), values = { citizenid } }
        end

        MySQL.transaction(queries, function(result2)
            if result2 then
                TriggerEvent('rx-log:server:CreateLog', 'joinleave', 'Character Deleted', 'red', '**' .. GetPlayerName(source) .. '** ' .. license .. ' deleted **' .. citizenid .. '**..')
            end
        end)
    else
        DropPlayer(source, Lang:t('info.exploit_dropped'))
        TriggerEvent('rx-log:server:CreateLog', 'anticheat', 'Anti-Cheat', 'white', GetPlayerName(source) .. ' Has Been Dropped For Character Deletion Exploit', true)
    end
end

function RXCore.Player.ForceDeleteCharacter(citizenid)
    local result = MySQL.scalar.await('SELECT license FROM players where citizenid = ?', { citizenid })
    if result then
        local query = 'DELETE FROM %s WHERE citizenid = ?'
        local tableCount = #playertables
        local queries = table.create(tableCount, 0)
        local Player = RXCore.Functions.GetPlayerByCitizenId(citizenid)

        if Player then
            DropPlayer(Player.PlayerData.source, 'An admin deleted the character which you are currently using')
        end
        for i = 1, tableCount do
            local v = playertables[i]
            queries[i] = { query = query:format(v.table), values = { citizenid } }
        end

        MySQL.transaction(queries, function(result2)
            if result2 then
                TriggerEvent('rx-log:server:CreateLog', 'joinleave', 'Character Force Deleted', 'red', 'Character **' .. citizenid .. '** got deleted')
            end
        end)
    end
end

-- Inventory Backwards Compatibility

function RXCore.Player.SaveInventory(source)
    if GetResourceState('rx-inventory') == 'missing' then return end
    exports['rx-inventory']:SaveInventory(source, false)
end

function RXCore.Player.SaveOfflineInventory(PlayerData)
    if GetResourceState('rx-inventory') == 'missing' then return end
    exports['rx-inventory']:SaveInventory(PlayerData, true)
end

function RXCore.Player.GetTotalWeight(items)
    if GetResourceState('rx-inventory') == 'missing' then return end
    return exports['rx-inventory']:GetTotalWeight(items)
end

function RXCore.Player.GetSlotsByItem(items, itemName)
    if GetResourceState('rx-inventory') == 'missing' then return end
    return exports['rx-inventory']:GetSlotsByItem(items, itemName)
end

function RXCore.Player.GetFirstSlotByItem(items, itemName)
    if GetResourceState('rx-inventory') == 'missing' then return end
    return exports['rx-inventory']:GetFirstSlotByItem(items, itemName)
end

-- Util Functions

function RXCore.Player.CreateCitizenId()
    local CitizenId = tostring(RXCore.Shared.RandomStr(3) .. RXCore.Shared.RandomInt(5)):upper()
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE citizenid = ?) AS uniqueCheck', { CitizenId })
    if result == 0 then return CitizenId end
    return RXCore.Player.CreateCitizenId()
end

function RXCore.Functions.CreateAccountNumber()
    local AccountNumber = 'US0' .. math.random(1, 9) .. 'RXCore' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99)
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(charinfo, "$.account")) = ?) AS uniqueCheck', { AccountNumber })
    if result == 0 then return AccountNumber end
    return RXCore.Functions.CreateAccountNumber()
end

function RXCore.Functions.CreatePhoneNumber()
    local PhoneNumber = math.random(100, 999) .. math.random(1000000, 9999999)
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(charinfo, "$.phone")) = ?) AS uniqueCheck', { PhoneNumber })
    if result == 0 then return PhoneNumber end
    return RXCore.Functions.CreatePhoneNumber()
end

function RXCore.Player.CreateFingerId()
    local FingerId = tostring(RXCore.Shared.RandomStr(2) .. RXCore.Shared.RandomInt(3) .. RXCore.Shared.RandomStr(1) .. RXCore.Shared.RandomInt(2) .. RXCore.Shared.RandomStr(3) .. RXCore.Shared.RandomInt(4))
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.fingerprint")) = ?) AS uniqueCheck', { FingerId })
    if result == 0 then return FingerId end
    return RXCore.Player.CreateFingerId()
end

function RXCore.Player.CreateWalletId()
    local WalletId = 'RX-' .. math.random(11111111, 99999999)
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.walletid")) = ?) AS uniqueCheck', { WalletId })
    if result == 0 then return WalletId end
    return RXCore.Player.CreateWalletId()
end

function RXCore.Player.CreateSerialNumber()
    local SerialNumber = math.random(11111111, 99999999)
    local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.phonedata.SerialNumber")) = ?) AS uniqueCheck', { SerialNumber })
    if result == 0 then return SerialNumber end
    return RXCore.Player.CreateSerialNumber()
end

PaycheckInterval() -- This starts the paycheck system
