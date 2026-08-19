--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

SafehouseVehicleProtectionServer = {
    OriginalFunctions = {
        Vehicles_Use_EngineDoor = Vehicles.Use.EngineDoor,
        Vehicles_Use_TrunkDoor = Vehicles.Use.TrunkDoor
    },
    Use = {}
}

function SafehouseVehicleProtectionServer.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.SafehouseVehicleProtection
end

function SafehouseVehicleProtectionServer.IsVehicleActionAllowed(vehicle, character)
    if openutils.IsVehicleCheat() then
        return true
    end

    local square = vehicle:getCurrentSquare()
    local x = math.floor(square:getX())
    local y = math.floor(square:getY())

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and not openutils.IsUsernameMemberOfSafehouse(character:getUsername(), safehouse) then
        return false
    end
    
    return true
end

-- EngineDoor rewrites original Vehicles.Use.EngineDoor function.
-- Forbids to open Engine Door if user is not permitted (when vehicle is inside others player's safehouse).
function SafehouseVehicleProtectionServer.Use.EngineDoor(vehicle, part, character)
    if SafehouseVehicleProtectionServer.IsEnabledOnServer() then
        if not SafehouseVehicleProtectionServer.IsVehicleActionAllowed(vehicle, character) then
            character:Say(getText("IGUI_PlayerText_VehicleIsInSafehouse"))
            logger.Debug("SafehouseVehicleProtectionServer: stopped EngineDoor action for " .. character:getUsername())

            return
        end
    end

    SafehouseVehicleProtectionServer.OriginalFunctions.Vehicles_Use_EngineDoor(vehicle, part, character)
end

-- TrunkDoor rewrites original Vehicles.Use.TrunkDoor function.
-- Forbids to open Trunk Door if user is not permitted (when vehicle is inside others player's safehouse).
function SafehouseVehicleProtectionServer.Use.TrunkDoor(vehicle, part, character)
    if SafehouseVehicleProtectionServer.IsEnabledOnServer() then
        if not SafehouseVehicleProtectionServer.IsVehicleActionAllowed(vehicle, character) then
            character:Say(getText("IGUI_PlayerText_VehicleIsInSafehouse"))
            logger.Debug("SafehouseVehicleProtectionServer: stopped TrunkDoor action for " .. character:getUsername())

            return
        end
    end

    SafehouseVehicleProtectionServer.OriginalFunctions.Vehicles_Use_TrunkDoor(vehicle, part, character)
end

Vehicles.Use.EngineDoor = SafehouseVehicleProtectionServer.Use.EngineDoor
Vehicles.Use.TrunkDoor = SafehouseVehicleProtectionServer.Use.TrunkDoor
