RXCore.Commands = {}
RXCore.Commands.List = {}
RXCore.Commands.IgnoreList = { -- Ignore old perm levels while keeping backwards compatibility
    ['god'] = true,            -- We don't need to create an ace because god is allowed all commands
    ['user'] = true            -- We don't need to create an ace because builtin.everyone
}

CreateThread(function() -- Add ace to node for perm checking
    local permissions = RXCore.Config.Server.Permissions
    for i = 1, #permissions do
        local permission = permissions[i]
        ExecuteCommand(('add_ace rxcore.%s %s allow'):format(permission, permission))
    end
end)

-- Register & Refresh Commands

function RXCore.Commands.Add(name, help, arguments, argsrequired, callback, permission, ...)
    local restricted = true                                  -- Default to restricted for all commands
    if not permission then permission = 'user' end           -- some commands don't pass permission level
    if permission == 'user' then restricted = false end      -- allow all users to use command

    RegisterCommand(name, function(source, args, rawCommand) -- Register command within fivem
        if argsrequired and #args < #arguments then
            return TriggerClientEvent('chat:addMessage', source, {
                color = { 255, 0, 0 },
                multiline = true,
                args = { 'System', Lang:t('error.missing_args2') }
            })
        end
        callback(source, args, rawCommand)
    end, restricted)

    local extraPerms = ... and table.pack(...) or nil
    if extraPerms then
        extraPerms[extraPerms.n + 1] = permission -- The `n` field is the number of arguments in the packed table
        extraPerms.n += 1
        permission = extraPerms
        for i = 1, permission.n do
            if not RXCore.Commands.IgnoreList[permission[i]] then -- only create aces for extra perm levels
                ExecuteCommand(('add_ace rxcore.%s command.%s allow'):format(permission[i], name))
            end
        end
        permission.n = nil
    else
        permission = tostring(permission:lower())
        if not RXCore.Commands.IgnoreList[permission] then -- only create aces for extra perm levels
            ExecuteCommand(('add_ace rxcore.%s command.%s allow'):format(permission, name))
        end
    end

    RXCore.Commands.List[name:lower()] = {
        name = name:lower(),
        permission = permission,
        help = help,
        arguments = arguments,
        argsrequired = argsrequired,
        callback = callback
    }
end

function RXCore.Commands.Refresh(source)
    local src = source
    local Player = RXCore.Functions.GetPlayer(src)
    local suggestions = {}
    if Player then
        for command, info in pairs(RXCore.Commands.List) do
            local hasPerm = IsPlayerAceAllowed(tostring(src), 'command.' .. command)
            if hasPerm then
                suggestions[#suggestions + 1] = {
                    name = '/' .. command,
                    help = info.help,
                    params = info.arguments
                }
            else
                TriggerClientEvent('chat:removeSuggestion', src, '/' .. command)
            end
        end
        TriggerClientEvent('chat:addSuggestions', src, suggestions)
    end
end

-- Teleport
RXCore.Commands.Add('tp', Lang:t('command.tp.help'), { { name = Lang:t('command.tp.params.x.name'), help = Lang:t('command.tp.params.x.help') }, { name = Lang:t('command.tp.params.y.name'), help = Lang:t('command.tp.params.y.help') }, { name = Lang:t('command.tp.params.z.name'), help = Lang:t('command.tp.params.z.help') } }, false, function(source, args)
    if args[1] and not args[2] and not args[3] then
        if tonumber(args[1]) then
            local target = GetPlayerPed(tonumber(args[1]))
            if target ~= 0 then
                local coords = GetEntityCoords(target)
                TriggerClientEvent('RXCore:Command:TeleportToPlayer', source, coords)
            else
                TriggerClientEvent('RXCore:Notify', source, Lang:t('error.not_online'), 'error')
            end
        else
            local location = RXShared.Locations[args[1]]
            if location then
                TriggerClientEvent('RXCore:Command:TeleportToCoords', source, location.x, location.y, location.z, location.w)
            else
                TriggerClientEvent('RXCore:Notify', source, Lang:t('error.location_not_exist'), 'error')
            end
        end
    else
        if args[1] and args[2] and args[3] then
            local x = tonumber((args[1]:gsub(',', ''))) + .0
            local y = tonumber((args[2]:gsub(',', ''))) + .0
            local z = tonumber((args[3]:gsub(',', ''))) + .0
            local heading = args[4] and tonumber((args[4]:gsub(',', ''))) + .0 or false
            if x ~= 0 and y ~= 0 and z ~= 0 then
                TriggerClientEvent('RXCore:Command:TeleportToCoords', source, x, y, z, heading)
            else
                TriggerClientEvent('RXCore:Notify', source, Lang:t('error.wrong_format'), 'error')
            end
        else
            TriggerClientEvent('RXCore:Notify', source, Lang:t('error.missing_args'), 'error')
        end
    end
end, 'admin')

RXCore.Commands.Add('tpm', Lang:t('command.tpm.help'), {}, false, function(source)
    TriggerClientEvent('RXCore:Command:GoToMarker', source)
end, 'admin')

RXCore.Commands.Add('togglepvp', Lang:t('command.togglepvp.help'), {}, false, function()
    RXCore.Config.Server.PVP = not RXCore.Config.Server.PVP
    TriggerClientEvent('RXCore:Client:PvpHasToggled', -1, RXCore.Config.Server.PVP)
end, 'admin')

-- Permissions

RXCore.Commands.Add('addpermission', Lang:t('command.addpermission.help'), { { name = Lang:t('command.addpermission.params.id.name'), help = Lang:t('command.addpermission.params.id.help') }, { name = Lang:t('command.addpermission.params.permission.name'), help = Lang:t('command.addpermission.params.permission.help') } }, true, function(source, args)
    local Player = RXCore.Functions.GetPlayer(tonumber(args[1]))
    local permission = tostring(args[2]):lower()
    if Player then
        RXCore.Functions.AddPermission(Player.PlayerData.source, permission)
    else
        TriggerClientEvent('RXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'god')

RXCore.Commands.Add('removepermission', Lang:t('command.removepermission.help'), { { name = Lang:t('command.removepermission.params.id.name'), help = Lang:t('command.removepermission.params.id.help') }, { name = Lang:t('command.removepermission.params.permission.name'), help = Lang:t('command.removepermission.params.permission.help') } }, true, function(source, args)
    local Player = RXCore.Functions.GetPlayer(tonumber(args[1]))
    local permission = tostring(args[2]):lower()
    if Player then
        RXCore.Functions.RemovePermission(Player.PlayerData.source, permission)
    else
        TriggerClientEvent('RXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'god')

-- Open & Close Server

RXCore.Commands.Add('openserver', Lang:t('command.openserver.help'), {}, false, function(source)
    if not RXCore.Config.Server.Closed then
        TriggerClientEvent('RXCore:Notify', source, Lang:t('error.server_already_open'), 'error')
        return
    end
    if RXCore.Functions.HasPermission(source, 'admin') then
        RXCore.Config.Server.Closed = false
        TriggerClientEvent('RXCore:Notify', source, Lang:t('success.server_opened'), 'success')
    else
        RXCore.Functions.Kick(source, Lang:t('error.no_permission'), nil, nil)
    end
end, 'admin')

RXCore.Commands.Add('closeserver', Lang:t('command.closeserver.help'), { { name = Lang:t('command.closeserver.params.reason.name'), help = Lang:t('command.closeserver.params.reason.help') } }, false, function(source, args)
    if RXCore.Config.Server.Closed then
        TriggerClientEvent('RXCore:Notify', source, Lang:t('error.server_already_closed'), 'error')
        return
    end
    if RXCore.Functions.HasPermission(source, 'admin') then
        local reason = args[1] or 'No reason specified'
        RXCore.Config.Server.Closed = true
        RXCore.Config.Server.ClosedReason = reason
        for k in pairs(RXCore.Players) do
            if not RXCore.Functions.HasPermission(k, RXCore.Config.Server.WhitelistPermission) then
                RXCore.Functions.Kick(k, reason, nil, nil)
            end
        end
        TriggerClientEvent('RXCore:Notify', source, Lang:t('success.server_closed'), 'success')
    else
        RXCore.Functions.Kick(source, Lang:t('error.no_permission'), nil, nil)
    end
end, 'admin')

-- Vehicle

RXCore.Commands.Add('car', Lang:t('command.car.help'), { { name = Lang:t('command.car.params.model.name'), help = Lang:t('command.car.params.model.help') } }, true, function(source, args)
    TriggerClientEvent('RXCore:Command:SpawnVehicle', source, args[1])
end, 'admin')

RXCore.Commands.Add('dv', Lang:t('command.dv.help'), {}, false, function(source)
    TriggerClientEvent('RXCore:Command:DeleteVehicle', source)
end, 'admin')

RXCore.Commands.Add('dvall', Lang:t('command.dvall.help'), {}, false, function()
    local vehicles = GetAllVehicles()
    for _, vehicle in ipairs(vehicles) do
        DeleteEntity(vehicle)
    end
end, 'admin')

-- Peds

RXCore.Commands.Add('dvp', Lang:t('command.dvp.help'), {}, false, function()
    local peds = GetAllPeds()
    for _, ped in ipairs(peds) do
        DeleteEntity(ped)
    end
end, 'admin')

-- Objects

RXCore.Commands.Add('dvo', Lang:t('command.dvo.help'), {}, false, function()
    local objects = GetAllObjects()
    for _, object in ipairs(objects) do
        DeleteEntity(object)
    end
end, 'admin')

-- Money

RXCore.Commands.Add('givemoney', Lang:t('command.givemoney.help'), { { name = Lang:t('command.givemoney.params.id.name'), help = Lang:t('command.givemoney.params.id.help') }, { name = Lang:t('command.givemoney.params.moneytype.name'), help = Lang:t('command.givemoney.params.moneytype.help') }, { name = Lang:t('command.givemoney.params.amount.name'), help = Lang:t('command.givemoney.params.amount.help') } }, true, function(source, args)
    local Player = RXCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.AddMoney(tostring(args[2]), tonumber(args[3]), 'Admin give money')
    else
        TriggerClientEvent('RXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

RXCore.Commands.Add('setmoney', Lang:t('command.setmoney.help'), { { name = Lang:t('command.setmoney.params.id.name'), help = Lang:t('command.setmoney.params.id.help') }, { name = Lang:t('command.setmoney.params.moneytype.name'), help = Lang:t('command.setmoney.params.moneytype.help') }, { name = Lang:t('command.setmoney.params.amount.name'), help = Lang:t('command.setmoney.params.amount.help') } }, true, function(source, args)
    local Player = RXCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetMoney(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('RXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

-- Job

RXCore.Commands.Add('job', Lang:t('command.job.help'), {}, false, function(source)
    local PlayerJob = RXCore.Functions.GetPlayer(source).PlayerData.job
    TriggerClientEvent('RXCore:Notify', source, Lang:t('info.job_info', { value = PlayerJob.label, value2 = PlayerJob.grade.name, value3 = PlayerJob.onduty }))
end, 'user')

RXCore.Commands.Add('setjob', Lang:t('command.setjob.help'), { { name = Lang:t('command.setjob.params.id.name'), help = Lang:t('command.setjob.params.id.help') }, { name = Lang:t('command.setjob.params.job.name'), help = Lang:t('command.setjob.params.job.help') }, { name = Lang:t('command.setjob.params.grade.name'), help = Lang:t('command.setjob.params.grade.help') } }, true, function(source, args)
    local Player = RXCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetJob(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('RXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

-- Gang

RXCore.Commands.Add('gang', Lang:t('command.gang.help'), {}, false, function(source)
    local PlayerGang = RXCore.Functions.GetPlayer(source).PlayerData.gang
    TriggerClientEvent('RXCore:Notify', source, Lang:t('info.gang_info', { value = PlayerGang.label, value2 = PlayerGang.grade.name }))
end, 'user')

RXCore.Commands.Add('setgang', Lang:t('command.setgang.help'), { { name = Lang:t('command.setgang.params.id.name'), help = Lang:t('command.setgang.params.id.help') }, { name = Lang:t('command.setgang.params.gang.name'), help = Lang:t('command.setgang.params.gang.help') }, { name = Lang:t('command.setgang.params.grade.name'), help = Lang:t('command.setgang.params.grade.help') } }, true, function(source, args)
    local Player = RXCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetGang(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('RXCore:Notify', source, Lang:t('error.not_online'), 'error')
    end
end, 'admin')

-- Out of Character Chat
RXCore.Commands.Add('ooc', Lang:t('command.ooc.help'), {}, false, function(source, args)
    local message = table.concat(args, ' ')
    local Players = RXCore.Functions.GetPlayers()
    local Player = RXCore.Functions.GetPlayer(source)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    for _, v in pairs(Players) do
        if v == source then
            TriggerClientEvent('chat:addMessage', v, {
                color = RXCore.Config.Commands.OOCColor,
                multiline = true,
                args = { 'OOC | ' .. GetPlayerName(source), message }
            })
        elseif #(playerCoords - GetEntityCoords(GetPlayerPed(v))) < 20.0 then
            TriggerClientEvent('chat:addMessage', v, {
                color = RXCore.Config.Commands.OOCColor,
                multiline = true,
                args = { 'OOC | ' .. GetPlayerName(source), message }
            })
        elseif RXCore.Functions.HasPermission(v, 'admin') then
            if RXCore.Functions.IsOptin(v) then
                TriggerClientEvent('chat:addMessage', v, {
                    color = RXCore.Config.Commands.OOCColor,
                    multiline = true,
                    args = { 'Proximity OOC | ' .. GetPlayerName(source), message }
                })
                TriggerEvent('rx-log:server:CreateLog', 'ooc', 'OOC', 'white', '**' .. GetPlayerName(source) .. '** (CitizenID: ' .. Player.PlayerData.citizenid .. ' | ID: ' .. source .. ') **Message:** ' .. message, false)
            end
        end
    end
end, 'user')

-- Me command

RXCore.Commands.Add('me', Lang:t('command.me.help'), { { name = Lang:t('command.me.params.message.name'), help = Lang:t('command.me.params.message.help') } }, false, function(source, args)
    if #args < 1 then
        TriggerClientEvent('RXCore:Notify', source, Lang:t('error.missing_args2'), 'error')
        return
    end
    local ped = GetPlayerPed(source)
    local pCoords = GetEntityCoords(ped)
    local msg = table.concat(args, ' '):gsub('[~<].-[>~]', '')
    local Players = RXCore.Functions.GetPlayers()
    for i = 1, #Players do
        local Player = Players[i]
        local target = GetPlayerPed(Player)
        local tCoords = GetEntityCoords(target)
        if target == ped or #(pCoords - tCoords) < 20 then
            TriggerClientEvent('RXCore:Command:ShowMe3D', Player, source, msg)
        end
    end
end, 'user')
