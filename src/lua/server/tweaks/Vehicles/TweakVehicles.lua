--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakVehicles = {
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
TweakVehicles.Use.EngineDoor = function(vehicle, part, character)
    if not SandboxVars.ServerTweaker.ProtectVehicleInSafehouse then
        TweakVehicles.Original.Use.EngineDoor(vehicle, part, character)
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

    TweakVehicles.Original.Use.EngineDoor(vehicle, part, character)
end

-- TrunkDoor rewrites original Vehicles.Use.TrunkDoor function.
-- Forbids to open Trunk Door if user is not permitted.
-- (Vehicle is inside other players safehouse).
TweakVehicles.Use.TrunkDoor = function(vehicle, part, character)
    if not SandboxVars.ServerTweaker.ProtectVehicleInSafehouse then
        TweakVehicles.Original.Use.TrunkDoor(vehicle, part, character)
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

    TweakVehicles.Original.Use.TrunkDoor(vehicle, part, character)
end

Vehicles.Use.EngineDoor = TweakVehicles.Use.EngineDoor;
Vehicles.Use.TrunkDoor = TweakVehicles.Use.TrunkDoor;
