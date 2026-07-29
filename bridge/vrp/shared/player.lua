RxBridge = RxBridge or {}
RxBridge.VRP = RxBridge.VRP or {}

function RxBridge.VRP.ToUserData(playerData)
    if not playerData then return {} end
    local charinfo = playerData.charinfo or {}
    return {
        user_id = playerData.citizenid,
        citizenid = playerData.citizenid,
        source = playerData.source,
        license = playerData.license,
        name = ('%s %s'):format(charinfo.firstname or '', charinfo.lastname or ''),
        firstname = charinfo.firstname,
        lastname = charinfo.lastname,
        job = playerData.job and playerData.job.name,
        money = playerData.money,
    }
end
