--[[
  Optional ox_lib TextUI → rx-core prompt strip

  Copy this file over:
    ox_lib/resource/interface/client/textui.lua

  Or merge the rx-core branch at the top of that file.

  Requires rx-core to start before (or with) ox_lib. Restart ox_lib after copying.
]]

local isOpen = false
local currentText

local function mapPosition(options)
    if not options or not options.position then return 'left' end
    if options.position == 'right-center' then return 'right' end
    return 'left'
end

---@param text string
---@param options? table
function lib.showTextUI(text, options)
    if currentText == text and isOpen then return end
    currentText = text
    isOpen = true
    exports['rx-core']:ShowTextUI(text, mapPosition(options))
end

function lib.hideTextUI()
    if not isOpen then return end
    isOpen = false
    currentText = nil
    exports['rx-core']:HideTextUI()
end

---@return boolean, string | nil
function lib.isTextUIOpen()
    return isOpen, currentText
end
