RxBridge = RxBridge or {}
RxBridge.ESX = RxBridge.ESX or {}

local accountLabels = {
    cash = 'Cash',
    money = 'Cash',
    bank = 'Bank',
    black_money = 'Dirty Money',
    crypto = 'Crypto',
}

--- Map RX money keys to ESX account names (cash -> money)
local function toEsxAccountName(moneyType)
    if moneyType == 'cash' then return 'money' end
    return moneyType
end

function RxBridge.ESX.ToEsxAccounts(money)
    local accounts = {}
    money = money or {}
    for moneyType, amount in pairs(money) do
        local name = toEsxAccountName(moneyType)
        accounts[#accounts + 1] = {
            name = name,
            money = amount,
            label = accountLabels[moneyType] or accountLabels[name] or moneyType,
        }
    end
    return accounts
end

function RxBridge.ESX.ToEsxJob(job)
    job = job or {}
    local grade = job.grade or {}
    return {
        name = job.name or 'unemployed',
        label = job.label or 'Unemployed',
        grade = grade.level or 0,
        grade_name = grade.name or 'unemployed',
        grade_label = grade.name or 'Unemployed',
        grade_salary = job.payment or 0,
        skin_male = {},
        skin_female = {},
        onDuty = job.onduty,
    }
end

function RxBridge.ESX.ToEsxPlayerData(playerData)
    if not playerData then return {} end

    local charinfo = playerData.charinfo or {}
    local position = playerData.position
    local coords = vector3(0.0, 0.0, 0.0)

    if type(position) == 'vector4' then
        coords = vector3(position.x, position.y, position.z)
    elseif type(position) == 'table' and position.x then
        coords = vector3(position.x, position.y, position.z or 0.0)
    end

    return {
        identifier = playerData.license or playerData.citizenid,
        citizenid = playerData.citizenid,
        accounts = RxBridge.ESX.ToEsxAccounts(playerData.money),
        armor = (playerData.metadata or {}).armor or 0,
        coords = coords,
        dateofbirth = charinfo.birthdate or '00-00-0000',
        firstname = charinfo.firstname or 'Firstname',
        lastname = charinfo.lastname or 'Lastname',
        height = 0,
        dead = (playerData.metadata or {}).isdead or false,
        inventory = playerData.items or {},
        job = RxBridge.ESX.ToEsxJob(playerData.job),
        loadout = {},
        money = playerData.money and (playerData.money.cash or playerData.money.money) or 0,
        sex = (charinfo.gender == 1) and 'f' or 'm',
        metadata = playerData.metadata or {},
    }
end

function RxBridge.ESX.WrapPlayer(rxPlayer)
    if not rxPlayer or not rxPlayer.PlayerData then return nil end

    local pd = rxPlayer.PlayerData
    local wrapped = {
        source = pd.source,
        identifier = pd.license,
        citizenid = pd.citizenid,
        PlayerData = pd,
        Functions = rxPlayer.Functions,
    }

    function wrapped.getIdentifier()
        return pd.license
    end

    function wrapped.getName()
        return ('%s %s'):format(pd.charinfo.firstname or '', pd.charinfo.lastname or '')
    end

    function wrapped.getJob()
        return RxBridge.ESX.ToEsxJob(pd.job)
    end

    function wrapped.getMoney(account)
        account = toEsxAccountName(account or 'money')
        if account == 'money' then
            return pd.money.cash or pd.money.money or 0
        end
        return pd.money[account] or 0
    end

    function wrapped.addMoney(account, amount, reason)
        account = account == 'money' and 'cash' or account
        return rxPlayer.Functions.AddMoney(account, amount, reason)
    end

    function wrapped.removeMoney(account, amount, reason)
        account = account == 'money' and 'cash' or account
        return rxPlayer.Functions.RemoveMoney(account, amount, reason)
    end

    function wrapped.setMoney(account, amount, reason)
        account = account == 'money' and 'cash' or account
        return rxPlayer.Functions.SetMoney(account, amount, reason)
    end

    function wrapped.getCoords(vector)
        local pos = pd.position
        if vector then
            return vector3(pos.x, pos.y, pos.z)
        end
        return pos
    end

    return wrapped
end
