local function getPlayerPed()
    if cache and cache.ped then
        return cache.ped
    end
    return PlayerPedId()
end

local PromptOwner = nil
local proximityPrompt = {
    text = nil,
    coords = nil,
    updated = 0,
    maxDist = 12.0,
}
local proximityShown = nil

local function hideText()
    PromptOwner = nil
    proximityShown = nil
    SendNUIMessage({
        action = 'HIDE_TEXT',
    })
end

local function drawText(text, position)
    if type(position) ~= 'string' then position = 'left' end
    PromptOwner = 'ui'
    proximityShown = nil

    SendNUIMessage({
        action = 'DRAW_TEXT',
        data = {
            text = text,
            position = position
        }
    })
end

local function changeText(text, position)
    if type(position) ~= 'string' then position = 'left' end
    PromptOwner = 'ui'

    SendNUIMessage({
        action = 'CHANGE_TEXT',
        data = {
            text = text,
            position = position
        }
    })
end

local function keyPressed()
    CreateThread(function()
        SendNUIMessage({
            action = 'KEY_PRESSED',
        })
        Wait(200)
        hideText()
    end)
end

local function stripGtaColors(text)
    if not text or text == '' then return '' end
    text = text:gsub('~%w~', '')
    text = text:gsub('~INPUT_CONTEXT~', 'E')
    text = text:gsub('~INPUT_DETONATE~', 'G')
    return (text:gsub('%s+', ' '):match('^%s*(.-)%s*$') or '')
end

local function normalizeProximityPrompt(text)
    text = stripGtaColors(text)
    local key, rest = text:match('%[([^%]]+)%]%s*(.*)')
    if key then
        rest = rest and rest:gsub('^%s+', '') or ''
        if rest ~= '' then
            return ('[%s] %s'):format(key, rest)
        end
        return ('[%s]'):format(key)
    end
    return text
end

local function updateProximityPrompt(x, y, z, text, maxDist)
    local playerCoords = GetEntityCoords(getPlayerPed())
    local target = vector3(x, y, z)
    maxDist = maxDist or 12.0

    if #(playerCoords - target) > maxDist then return end

    proximityPrompt.text = normalizeProximityPrompt(text)
    proximityPrompt.coords = target
    proximityPrompt.updated = GetGameTimer()
    proximityPrompt.maxDist = maxDist
end

local function drawText3D(x, y, z, text, maxDist)
    updateProximityPrompt(x, y, z, text, maxDist)
end

local function drawText3Ds(a, b, c, d, maxDist)
    if type(a) == 'number' and type(b) == 'number' and type(c) == 'number' then
        drawText3D(a, b, c, d, maxDist)
        return
    end

    local coords, text = a, b
    if type(coords) == 'vector3' then
        drawText3D(coords.x, coords.y, coords.z, text, maxDist)
    elseif type(coords) == 'table' then
        drawText3D(coords.x or coords[1], coords.y or coords[2], coords.z or coords[3], text, maxDist)
    end
end

CreateThread(function()
    while true do
        Wait(50)
        if PromptOwner == 'ui' then goto continue end

        local now = GetGameTimer()
        if proximityPrompt.updated > 0 and (now - proximityPrompt.updated) < 200 then
            local playerCoords = GetEntityCoords(getPlayerPed())
            if #(playerCoords - proximityPrompt.coords) <= proximityPrompt.maxDist then
                if proximityShown ~= proximityPrompt.text then
                    proximityShown = proximityPrompt.text
                    PromptOwner = 'proximity'
                    SendNUIMessage({
                        action = 'DRAW_TEXT',
                        data = { text = proximityShown, position = 'left' }
                    })
                end
            elseif proximityShown and PromptOwner == 'proximity' then
                proximityShown = nil
                hideText()
            end
        elseif proximityShown and PromptOwner == 'proximity' then
            proximityPrompt.updated = 0
            hideText()
        end

        ::continue::
    end
end)

-- ox_lib-style aliases (routes to the same NUI prompt strip)
local function showTextUI(text, position)
    drawText(text, position)
end

local function hideTextUI()
    hideText()
end

RegisterNetEvent('rx-core:client:DrawText', function(text, position)
    drawText(text, position)
end)

RegisterNetEvent('rx-core:client:ChangeText', function(text, position)
    changeText(text, position)
end)

RegisterNetEvent('rx-core:client:HideText', function()
    hideText()
end)

RegisterNetEvent('rx-core:client:KeyPressed', function()
    keyPressed()
end)

exports('DrawText', drawText)
exports('ChangeText', changeText)
exports('HideText', hideText)
exports('KeyPressed', keyPressed)
exports('DrawText3D', drawText3D)
exports('DrawText3Ds', drawText3Ds)
exports('ShowTextUI', showTextUI)
exports('HideTextUI', hideTextUI)
