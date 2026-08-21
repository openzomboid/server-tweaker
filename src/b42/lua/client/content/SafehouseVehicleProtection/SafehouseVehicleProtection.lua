--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

--
-- TODO: Add red text to the bottom right corner when driving into someone else's Safehouse
--

local logger = ConsoleLogger.new()

SafehouseVehicleProtection = {
    OriginalFunctions = {
        ISVehicleMenu_doTowingMenu = ISVehicleMenu.doTowingMenu,
        ISVehicleMenu_OnFillWorldObjectContextMenu = ISVehicleMenu.OnFillWorldObjectContextMenu,
        ISVehicleMenu_showRadialMenuOutside = ISVehicleMenu.showRadialMenuOutside,
        ISVehicleMenu_onEnter = ISVehicleMenu.onEnter,
        ISVehicleMenu_onEnter2 = ISVehicleMenu.onEnter2,
        ISVehicleMenu_onEnterAux = ISVehicleMenu.onEnterAux,
        ISVehicleMenu_onEnterAux2 = ISVehicleMenu.onEnterAux2,
    }
}

-- IsEnabledOnServer checks if the vehicle anti-theft system is active on the server.
-- It reads the current configuration state directly from the sandbox variable settings.
function SafehouseVehicleProtection.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.SafehouseVehicleProtection
end

-- IsVehicleActionAllowed evaluates whether a character is permitted to interact with a specific
-- vehicle. It bypasses constraints if vehicle cheats are active, maps the vehicle coordinates to
-- spatial safehouses, and blocks access if the player is not a registered member.
function SafehouseVehicleProtection.IsVehicleActionAllowed(vehicle, character)
    if openutils.IsVehicleCheat() then
        logger.Debug("SafehouseVehicleProtection: IsVehicleCheat is enabled for " .. character:getUsername())

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

-- doTowingMenu rewrites original ISVehicleMenu.doTowingMenu function.
-- Hides "Attach" key from Radial Menu if user is not permitted (when vehicle is inside others player's safehouse).
function SafehouseVehicleProtection.doTowingMenu(character, vehicle, menu)
    if not SafehouseVehicleProtection.IsEnabledOnServer() then
        SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_doTowingMenu(character, vehicle, menu)

        return
    end

    local character = character

    if vehicle:getVehicleTowing() then
        menu:addSlice(getText("ContextMenu_Vehicle_DetachTrailer"), getTexture("media/ui/ZoomOut.png"), ISVehicleMenu.onDetachTrailer, character, vehicle, vehicle:getTowAttachmentSelf())
        return
    end

    if vehicle:getVehicleTowedBy() then
        menu:addSlice(getText("ContextMenu_Vehicle_DetachTrailer"), getTexture("media/ui/ZoomOut.png"), ISVehicleMenu.onDetachTrailer, character, vehicle:getVehicleTowedBy(), vehicle:getVehicleTowedBy():getTowAttachmentSelf())
        return
    end

    local attachments = {
        { attachmentA = "trailer", attachmentB = "trailer" },
        { attachmentA = "trailerfront", attachmentB = "trailerfront" },
        { attachmentA = "trailer", attachmentB = "trailerfront" },
        { attachmentA = "trailerfront", attachmentB = "trailer" }
    }

    for _, item in pairs(attachments) do
        local attachmentA, attachmentB = item.attachmentA, item.attachmentB
        local vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(vehicle:getSquare(), vehicle, attachmentA, attachmentB)

        if vehicleB then
            if not SafehouseVehicleProtection.IsVehicleActionAllowed(vehicleB, character) then
                logger.Debug("SafehouseVehicleProtection: stopped doTowingMenu action for " .. character:getUsername(), {attachmentA = attachmentA, attachmentB = attachmentB})

                return
            end

            SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_doTowingMenu(character, vehicle, menu)

            return
        end
    end

    SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_doTowingMenu(character, vehicle, menu)
end

-- showRadialMenuOutside rewrites original ISVehicleMenu.showRadialMenuOutside function.
-- Hides RadialMenu if user is not permitted (when vehicle is inside others player's safehouse).
function SafehouseVehicleProtection.showRadialMenuOutside(character)
    if not SafehouseVehicleProtection.IsEnabledOnServer() then
        SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_showRadialMenuOutside(character)

        return
    end

    if character:getVehicle() then
        return
    end

    local vehicle = ISVehicleMenu.getVehicleToInteractWith(character)
    if not vehicle then
        return
    end

    if not SafehouseVehicleProtection.IsVehicleActionAllowed(vehicle, character) then
        character:Say(getText("IGUI_PlayerText_VehicleInteractionUnavailable"))
        logger.Debug("SafehouseVehicleProtection: stopped showRadialMenuOutside action for " .. character:getUsername())

        return
    end

    SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_showRadialMenuOutside(character)
end

-- onEnter rewrites original ISVehicleMenu.onEnter function.
-- Forbids to enter Vehicle if user is not permitted (when vehicle is inside others player's safehouse).
function SafehouseVehicleProtection.onEnter(character, vehicle, seat)
    if not SafehouseVehicleProtection.IsEnabledOnServer() then
        SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_onEnter(character, vehicle, seat)

        return
    end

    if not SafehouseVehicleProtection.IsVehicleActionAllowed(vehicle, character) then
        character:Say(getText("IGUI_PlayerText_VehicleInteractionUnavailable"))
        logger.Debug("SafehouseVehicleProtection: stopped onEnter action for " .. character:getUsername())

        return
    end

    SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_onEnter(character, vehicle, seat)
end

-- onEnter2 rewrites original ISVehicleMenu.onEnter2 function.
-- Forbids to enter Vehicle if user is not permitted (when vehicle is inside others player's safehouse).
function SafehouseVehicleProtection.onEnter2(character, vehicle, seat)
    if not SafehouseVehicleProtection.IsEnabledOnServer() then
        SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_onEnter2(character, vehicle, seat)

        return
    end

    if not SafehouseVehicleProtection.IsVehicleActionAllowed(vehicle, character) then
        character:Say(getText("IGUI_PlayerText_VehicleInteractionUnavailable"))
        logger.Debug("SafehouseVehicleProtection: stopped onEnter2 action for " .. character:getUsername())

        return
    end

    SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_onEnter2(character, vehicle, seat)
end

-- onEnterAux rewrites original ISVehicleMenu.onEnterAux function.
-- Forbids to enter Vehicle if user is not permitted (when vehicle is inside others player's safehouse).
function SafehouseVehicleProtection.onEnterAux(character, vehicle, seat)
    if not SafehouseVehicleProtection.IsEnabledOnServer() then
        SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_onEnterAux(character, vehicle, seat)

        return
    end

    if not SafehouseVehicleProtection.IsVehicleActionAllowed(vehicle, character) then
        logger.Debug("SafehouseVehicleProtection: stopped onEnterAux action for " .. character:getUsername())

        return
    end

    SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_onEnterAux(character, vehicle, seat)
end

-- onEnterAux2 rewrites original ISVehicleMenu.onEnterAux2 function.
-- Forbids to enter Vehicle if user is not permitted (when vehicle is inside others player's safehouse).
function SafehouseVehicleProtection.onEnterAux2(character, vehicle, seat)
    if not SafehouseVehicleProtection.IsEnabledOnServer() then
        SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_onEnterAux2(character, vehicle, seat)

        return
    end

    if not SafehouseVehicleProtection.IsVehicleActionAllowed(vehicle, character) then
        character:Say(getText("IGUI_PlayerText_VehicleInteractionUnavailable"))
        logger.Debug("SafehouseVehicleProtection: stopped onEnterAux2 action for " .. character:getUsername())

        return
    end

    SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_onEnterAux2(character, vehicle, seat)
end

-- OnFillWorldObjectContextMenu rewrites original ISVehicleMenu.OnFillWorldObjectContextMenu function.
-- Hides "Vehicle Mechanics" menu if user is not permitted (when vehicle is inside others player's safehouse).
function SafehouseVehicleProtection.OnFillWorldObjectContextMenu(player, context, worldobjects, test)
    if not SafehouseVehicleProtection.IsEnabledOnServer() or openutils.IsVehicleCheat then
        SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_OnFillWorldObjectContextMenu(player, context, worldobjects, test)

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

    if not SafehouseVehicleProtection.IsVehicleActionAllowed(vehicle, character) then
        character:Say(getText("IGUI_PlayerText_VehicleInteractionUnavailable"))
        logger.Debug("SafehouseVehicleProtection: stopped OnFillWorldObjectContextMenu action for " .. character:getUsername())

        return
    end

    SafehouseVehicleProtection.OriginalFunctions.ISVehicleMenu_OnFillWorldObjectContextMenu(player, context, worldobjects, test)
end

-- DoContextMenu injects custom status indicators into the player's world interaction menu.
-- It validates server configuration, checks for a valid vehicle under the cursor, and appends
-- an informative safehouse indicator option if the vehicle is parked within a protected zone.
function SafehouseVehicleProtection.DoContextMenu(player, context, worldobjects, test)
    if not SafehouseVehicleProtection.IsEnabledOnServer() then
        return
    end

    if not isClient() then return true end
    if test and ISWorldObjectContextMenu.Test then return true end

    local square = openutils.GetSquareFromWorldObjects(worldobjects)
    if not square or not square:getVehicleContainer() then
        return
    end

    local vehicle = square:getVehicleContainer()
    if not vehicle then
        return
    end

    local character = getSpecificPlayer(player)

    local square = vehicle:getCurrentSquare()
    local x = math.floor(square:getX())
    local y = math.floor(square:getY())

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and openutils.IsUsernameMemberOfSafehouse(character:getUsername(), safehouse) then
        --character:Say(getText("IGUI_PlayerText_VehicleSafe"))
        local option = context:addOption(getText("IGUI_PlayerText_VehicleSafe"), worldobjects, function() end)
        option.notAvailable = true
    end
end

ISVehicleMenu.doTowingMenu = SafehouseVehicleProtection.doTowingMenu;
ISVehicleMenu.showRadialMenuOutside = SafehouseVehicleProtection.showRadialMenuOutside;
ISVehicleMenu.onEnter = SafehouseVehicleProtection.onEnter;
ISVehicleMenu.onEnter2 = SafehouseVehicleProtection.onEnter2;
ISVehicleMenu.onEnterAux = SafehouseVehicleProtection.onEnterAux;
ISVehicleMenu.onEnterAux2 = SafehouseVehicleProtection.onEnterAux2;

Events.OnFillWorldObjectContextMenu.Remove(ISVehicleMenu.OnFillWorldObjectContextMenu)
Events.OnFillWorldObjectContextMenu.Add(SafehouseVehicleProtection.OnFillWorldObjectContextMenu)

Events.OnFillWorldObjectContextMenu.Add(SafehouseVehicleProtection.DoContextMenu)
