RXCore = {}
RXCore.PlayerData = {}
RXCore.Config = RXConfig
RXCore.Shared = RXShared
RXCore.ClientCallbacks = {}
RXCore.ServerCallbacks = {}

-- Get the full RXCore object (default behavior):
-- local RXCore = GetCoreObject()

-- Get only specific parts of RXCore:
-- local RXCore = GetCoreObject({'Players', 'Config'})

exports('GetCoreObject', RxBridge.GetCoreObject)

local function GetSharedItems()
    return RXShared.Items
end
exports('GetSharedItems', GetSharedItems)

local function GetSharedVehicles()
    return RXShared.Vehicles
end
exports('GetSharedVehicles', GetSharedVehicles)

local function GetSharedWeapons()
    return RXShared.Weapons
end
exports('GetSharedWeapons', GetSharedWeapons)

local function GetSharedJobs()
    return RXShared.Jobs
end
exports('GetSharedJobs', GetSharedJobs)

local function GetSharedGangs()
    return RXShared.Gangs
end
exports('GetSharedGangs', GetSharedGangs)
