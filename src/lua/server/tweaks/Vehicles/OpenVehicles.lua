--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

OpenVehicles = {
    Original = {
        Use = {
            EngineDoor = Vehicles.Use.EngineDoor,
            TrunkDoor = Vehicles.Use.TrunkDoor,
        }
    },
    Use = {},
}

-- EngineDoor rewrites original Vehicles.Use.EngineDoor function.
-- Forbids to open Engine Door if user is not permitted.
-- (Vehicle is inside other players safehouse).
OpenVehicles.Use.EngineDoor = function(vehicle, part, character)
    if not SandboxVars.ServerTweaker.ProtectVehicleInSafehouse then
        OpenVehicles.Original.Use.EngineDoor(vehicle, part, character)
        return
    end

    local square = vehicle:getCurrentSquare()
    local x = math.floor(square:getX())
    local y = math.floor(square:getY())

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and not openutils.IsPlayerMemmberOfSafehouse(character, safehouse) then
        character:Say(getText("IGUI_PlayerText_VehicleIsInSafehouse"))
        return
    end

    OpenVehicles.Original.Use.EngineDoor(vehicle, part, character)
end

-- TrunkDoor rewrites original Vehicles.Use.TrunkDoor function.
-- Forbids to open Trunk Door if user is not permitted.
-- (Vehicle is inside other players safehouse).
OpenVehicles.Use.TrunkDoor = function(vehicle, part, character)
    if not SandboxVars.ServerTweaker.ProtectVehicleInSafehouse then
        OpenVehicles.Original.Use.TrunkDoor(vehicle, part, character)
        return
    end

    local square = vehicle:getCurrentSquare()
    local x = math.floor(square:getX())
    local y = math.floor(square:getY())

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and not openutils.IsPlayerMemmberOfSafehouse(character, safehouse) then
        character:Say(getText("IGUI_PlayerText_VehicleIsInSafehouse"))
        return
    end

    OpenVehicles.Original.Use.TrunkDoor(vehicle, part, character)
end

Vehicles.Use.EngineDoor = OpenVehicles.Use.EngineDoor;
Vehicles.Use.TrunkDoor = OpenVehicles.Use.TrunkDoor;
