RxBridge = RxBridge or {}
RxBridge.NDCore = RxBridge.NDCore or {}

function RxBridge.NDCore.ToCharacter(playerData, rxPlayer)
    if not playerData then return {} end

    local charinfo = playerData.charinfo or {}
    local job = playerData.job or {}
    local money = playerData.money or {}
    local metadata = playerData.metadata or {}

    local character = {
        source = playerData.source,
        id = playerData.citizenid,
        citizenid = playerData.citizenid,
        license = playerData.license,
        firstname = charinfo.firstname or 'Firstname',
        lastname = charinfo.lastname or 'Lastname',
        dob = charinfo.birthdate or '00-00-0000',
        gender = charinfo.gender or 0,
        phone = charinfo.phone,
        cash = money.cash or 0,
        bank = money.bank or 0,
        job = job.name or 'unemployed',
        jobInfo = job,
        metadata = metadata,
        position = playerData.position,
        inventory = playerData.items or {},
    }

    if rxPlayer and rxPlayer.Functions then
        character.Functions = rxPlayer.Functions
    end

    return character
end
