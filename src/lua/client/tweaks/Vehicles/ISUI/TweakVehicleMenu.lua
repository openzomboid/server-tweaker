--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local BlowTorchDrainableUsesNeeded = 10

local function predicateWeldingMask(item)
    return item:hasTag("WeldingMask") or item:getType() == "WeldingMask"
end

local function predicateBlowTorch(item)
    return (item:hasTag("BlowTorch") or item:getType() == "BlowTorch") and item:getDrainableUsesInt() >= BlowTorchDrainableUsesNeeded
end

TweakVehicleMenu = {
    Original = {
        doTowingMenu = ISVehicleMenu.doTowingMenu,
        OnFillWorldObjectContextMenu = ISVehicleMenu.OnFillWorldObjectContextMenu,
        showRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside,
        onEnter = ISVehicleMenu.onEnter,
        onEnter2 = ISVehicleMenu.onEnter2,
        onEnterAux = ISVehicleMenu.onEnterAux,
        onEnterAux2 = ISVehicleMenu.onEnterAux2,
    }
}

-- doTowingMenu rewrites original ISVehicleMenu.doTowingMenu function.
-- hides "Attach" key from Radial Menu if user is not permitted.
-- (Vehicle is inside other players safehouse).
TweakVehicleMenu.doTowingMenu = function(playerObj, vehicle, menu)
    if not SandboxVars.ServerTweaker.ProtectVehicleInSafehouse then
        TweakVehicleMenu.Original.doTowingMenu(playerObj, vehicle, menu)
        return
    end

    if vehicle:getVehicleTowing() then
        menu:addSlice(getText("ContextMenu_Vehicle_DetachTrailer"), getTexture("media/ui/ZoomOut.png"), ISVehicleMenu.onDetachTrailer, playerObj, vehicle, vehicle:getTowAttachmentSelf())
        return
    end
    if vehicle:getVehicleTowedBy() then
        menu:addSlice(getText("ContextMenu_Vehicle_DetachTrailer"), getTexture("media/ui/ZoomOut.png"), ISVehicleMenu.onDetachTrailer, playerObj, vehicle:getVehicleTowedBy(), vehicle:getVehicleTowedBy():getTowAttachmentSelf())
        return
    end

    local square = vehicle:getCurrentSquare()
    local x = math.floor(square:getX())
    local y = math.floor(square:getY())

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and not openutils.IsPlayerMemmberOfSafehouse(playerObj, safehouse) then
        return
    end

    local attachmentA, attachmentB = "trailer", "trailer"
    local vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(vehicle:getSquare(), vehicle, attachmentA, attachmentB)
    if vehicleB then
        local squareB = vehicleB:getCurrentSquare()
        local xB = math.floor(squareB:getX())
        local yB = math.floor(squareB:getY())

        local safehouseB = openutils.GetSafehouseByXY(xB, yB)
        if safehouseB and not openutils.IsPlayerMemmberOfSafehouse(playerObj, safehouseB) then
            return
        end

        local aName = ISVehicleMenu.getVehicleDisplayName(vehicle)
        local bName = ISVehicleMenu.getVehicleDisplayName(vehicleB)
        local attachNameA = getText("IGUI_TrailerAttachName_" .. attachmentA)
        local attachNameB = getText("IGUI_TrailerAttachName_" .. attachmentB)
        local burntA = string.contains(vehicle:getScriptName(), "Burnt")
        local trailerA = string.contains(vehicle:getScriptName(), "Trailer")
        local trailerB = string.contains(vehicleB:getScriptName(), "Trailer")
        local vehicleTowing = vehicle
        if burntA or trailerA then
            vehicleTowing = vehicleB
        end
        local text = getText("ContextMenu_Vehicle_AttachVehicle", aName, bName, attachNameA, attachNameB);
        if trailerA or trailerB then
            text = getText("ContextMenu_Vehicle_AttachTrailer");
        end
        menu:addSlice(text, getTexture("media/ui/ZoomIn.png"), ISVehicleMenu.onAttachTrailer, playerObj, vehicleTowing, attachmentA, attachmentB)
        return
    end

    attachmentA, attachmentB = "trailerfront", "trailerfront"
    vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(vehicle:getSquare(), vehicle, attachmentA, attachmentB)
    if vehicleB then
        local squareB = vehicleB:getCurrentSquare()
        local xB = math.floor(squareB:getX())
        local yB = math.floor(squareB:getY())

        local safehouseB = openutils.GetSafehouseByXY(xB, yB)
        if safehouseB and not openutils.IsPlayerMemmberOfSafehouse(playerObj, safehouseB) then
            return
        end

        local aName = ISVehicleMenu.getVehicleDisplayName(vehicleB)
        local bName = ISVehicleMenu.getVehicleDisplayName(vehicle)
        local attachNameA = getText("IGUI_TrailerAttachName_" .. attachmentA)
        local attachNameB = getText("IGUI_TrailerAttachName_" .. attachmentB)
        local text = getText("ContextMenu_Vehicle_AttachVehicle", aName, bName, attachNameA, attachNameB);
        menu:addSlice(text, getTexture("media/ui/ZoomIn.png"), ISVehicleMenu.onAttachTrailer, playerObj, vehicle, attachmentB, attachmentA)
        return
    end

    attachmentA, attachmentB = "trailer", "trailerfront"
    vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(vehicle:getSquare(), vehicle, attachmentA, attachmentB)
    if vehicleB then
        local squareB = vehicleB:getCurrentSquare()
        local xB = math.floor(squareB:getX())
        local yB = math.floor(squareB:getY())

        local safehouseB = openutils.GetSafehouseByXY(xB, yB)
        if safehouseB and not openutils.IsPlayerMemmberOfSafehouse(playerObj, safehouseB) then
            return
        end

        local aName = ISVehicleMenu.getVehicleDisplayName(vehicle)
        local bName = ISVehicleMenu.getVehicleDisplayName(vehicleB)
        local attachNameA = getText("IGUI_TrailerAttachName_" .. attachmentA)
        local attachNameB = getText("IGUI_TrailerAttachName_" .. attachmentB)
        local attachName = getText("IGUI_TrailerAttachName_" .. attachmentA)
        local text = getText("ContextMenu_Vehicle_AttachVehicle", aName, bName, attachNameA, attachNameB);
        menu:addSlice(text, getTexture("media/ui/ZoomIn.png"), ISVehicleMenu.onAttachTrailer, playerObj, vehicle, attachmentA, attachmentB)
        return
    end

    attachmentA, attachmentB = "trailerfront", "trailer"
    vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(vehicle:getSquare(), vehicle, attachmentA, attachmentB)
    if vehicleB then
        local squareB = vehicleB:getCurrentSquare()
        local xB = math.floor(squareB:getX())
        local yB = math.floor(squareB:getY())

        local safehouseB = openutils.GetSafehouseByXY(xB, yB)
        if safehouseB and not openutils.IsPlayerMemmberOfSafehouse(playerObj, safehouseB) then
            return
        end

        local aName = ISVehicleMenu.getVehicleDisplayName(vehicleB)
        local bName = ISVehicleMenu.getVehicleDisplayName(vehicle)
        local attachNameA = getText("IGUI_TrailerAttachName_" .. attachmentA)
        local attachNameB = getText("IGUI_TrailerAttachName_" .. attachmentB)
        local text = getText("ContextMenu_Vehicle_AttachVehicle", aName, bName, attachNameA, attachNameB);
        menu:addSlice(text, getTexture("media/ui/ZoomIn.png"), ISVehicleMenu.onAttachTrailer, playerObj, vehicleB, attachmentB, attachmentA)
        return
    end
end

-- OnFillWorldObjectContextMenu rewrites original ISVehicleMenu.OnFillWorldObjectContextMenu function.
-- hides "Vehicle Mechanics" menu if user is not permitted.
-- (Vehicle is inside other players safehouse).
TweakVehicleMenu.OnFillWorldObjectContextMenu = function(player, context, worldobjects, test)
    if not SandboxVars.ServerTweaker.ProtectVehicleInSafehouse then
        TweakVehicleMenu.Original.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
        return
    end

    local cheat = getCore():getDebug() and getDebugOptions():getBoolean("Cheat.Vehicle.MechanicsAnywhere")
    if ISVehicleMechanics.cheat or cheat then
        TweakVehicleMenu.Original.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
        return
    end

    local character = getSpecificPlayer(player)

    if character:getVehicle() then
        return
    end

    local vehicle = IsoObjectPicker.Instance:PickVehicle(getMouseXScaled(), getMouseYScaled())
    if not vehicle then
        return
    end

    local square = vehicle:getCurrentSquare()
    local x = math.floor(square:getX())
    local y = math.floor(square:getY())

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and not openutils.IsPlayerMemmberOfSafehouse(character, safehouse) then
        return
    end

    TweakVehicleMenu.Original.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
end

-- showRadialMenuOutside rewrites original ISVehicleMenu.showRadialMenuOutside function.
-- Hides RadialMenu if user is not permitted.
-- (Vehicle is inside other players safehouse).
TweakVehicleMenu.showRadialMenuOutside = function(character)
    if not SandboxVars.ServerTweaker.ProtectVehicleInSafehouse then
        TweakVehicleMenu.Original.showRadialMenuOutside(character)
        return
    end

    local cheat = getCore():getDebug() and getDebugOptions():getBoolean("Cheat.Vehicle.MechanicsAnywhere")
    if ISVehicleMechanics.cheat or cheat then
        TweakVehicleMenu.Original.showRadialMenuOutside(character)
        return
    end

    if character:getVehicle() then
        return
    end

    local vehicle = ISVehicleMenu.getVehicleToInteractWith(character)
    if not vehicle then
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

    TweakVehicleMenu.Original.showRadialMenuOutside(character)
end

-- onEnter rewrites original ISVehicleMenu.onEnter function.
-- Forbids to enter Vehicle if user is not permitted.
-- (Vehicle is inside other players safehouse).
TweakVehicleMenu.onEnter = function(playerObj, vehicle, seat)
    if not SandboxVars.ServerTweaker.ProtectVehicleInSafehouse then
        TweakVehicleMenu.Original.onEnter(playerObj, vehicle, seat)
        return
    end

    local square = vehicle:getCurrentSquare()
    local x = math.floor(square:getX())
    local y = math.floor(square:getY())

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and not openutils.IsPlayerMemmberOfSafehouse(playerObj, safehouse) then
        playerObj:Say(getText("IGUI_PlayerText_VehicleIsInSafehouse"))
        return
    end

    TweakVehicleMenu.Original.onEnter(playerObj, vehicle, seat)
end

-- onEnter2 rewrites original ISVehicleMenu.onEnter2 function.
-- Forbids to enter Vehicle if user is not permitted.
-- (Vehicle is inside other players safehouse).
TweakVehicleMenu.onEnter2 = function(playerObj, vehicle, seat)
    if not SandboxVars.ServerTweaker.ProtectVehicleInSafehouse then
        TweakVehicleMenu.Original.onEnter2(playerObj, vehicle, seat)
        return
    end

    local square = vehicle:getCurrentSquare()
    local x = math.floor(square:getX())
    local y = math.floor(square:getY())

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and not openutils.IsPlayerMemmberOfSafehouse(playerObj, safehouse) then
        playerObj:Say(getText("IGUI_PlayerText_VehicleIsInSafehouse"))
        return
    end

    TweakVehicleMenu.Original.onEnter2(playerObj, vehicle, seat)
end

-- onEnterAux rewrites original ISVehicleMenu.onEnterAux function.
-- Forbids to enter Vehicle if user is not permitted.
-- (Vehicle is inside other players safehouse).
TweakVehicleMenu.onEnterAux = function(playerObj, vehicle, seat)
    if not SandboxVars.ServerTweaker.ProtectVehicleInSafehouse then
        TweakVehicleMenu.Original.onEnterAux(playerObj, vehicle, seat)
        return
    end

    local square = vehicle:getCurrentSquare()
    local x = math.floor(square:getX())
    local y = math.floor(square:getY())

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and not openutils.IsPlayerMemmberOfSafehouse(playerObj, safehouse) then
        playerObj:Say(getText("IGUI_PlayerText_VehicleIsInSafehouse"))
        return
    end

    TweakVehicleMenu.Original.onEnterAux(playerObj, vehicle, seat)
end

-- onEnterAux2 rewrites original ISVehicleMenu.onEnterAux2 function.
-- Forbids to enter Vehicle if user is not permitted.
-- (Vehicle is inside other players safehouse).
TweakVehicleMenu.onEnterAux2 = function(playerObj, vehicle, seat)
    if not SandboxVars.ServerTweaker.ProtectVehicleInSafehouse then
        TweakVehicleMenu.Original.onEnterAux2(playerObj, vehicle, seat)
        return
    end

    local square = vehicle:getCurrentSquare()
    local x = math.floor(square:getX())
    local y = math.floor(square:getY())

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and not openutils.IsPlayerMemmberOfSafehouse(playerObj, safehouse) then
        playerObj:Say(getText("IGUI_PlayerText_VehicleIsInSafehouse"))
        return
    end

    TweakVehicleMenu.Original.onEnterAux2(playerObj, vehicle, seat)
end

-- onDisassembleVehicle adds DisassembleVehicle operation to ISTimedActionQueue.
function TweakVehicleMenu.onDisassembleVehicle(player, vehicle)
    if luautils.walkAdj(player, vehicle:getSquare()) then
        ISWorldObjectContextMenu.equip(player, player:getPrimaryHandItem(), predicateBlowTorch, true);
        local mask = player:getInventory():getFirstEvalRecurse(predicateWeldingMask);
        if mask then
            ISInventoryPaneContextMenu.wearItem(mask, player:getPlayerNum());
        end
        ISTimedActionQueue.add(DisassembleVehicle:new(player, vehicle));
    end
end

ISVehicleMenu.doTowingMenu = TweakVehicleMenu.doTowingMenu;
ISVehicleMenu.showRadialMenuOutside = TweakVehicleMenu.showRadialMenuOutside;
ISVehicleMenu.onEnter = TweakVehicleMenu.onEnter;
ISVehicleMenu.onEnter2 = TweakVehicleMenu.onEnter2;
ISVehicleMenu.onEnterAux = TweakVehicleMenu.onEnterAux;
ISVehicleMenu.onEnterAux2 = TweakVehicleMenu.onEnterAux2;

Events.OnFillWorldObjectContextMenu.Remove(ISVehicleMenu.OnFillWorldObjectContextMenu)
Events.OnFillWorldObjectContextMenu.Add(TweakVehicleMenu.OnFillWorldObjectContextMenu)
