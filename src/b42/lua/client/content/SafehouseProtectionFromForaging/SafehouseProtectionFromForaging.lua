--
-- Copyright (c) 2026 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

SafehouseProtectionFromForaging = {
    OriginalFunctions = {
        ISBaseIcon_doContextMenu      = ISBaseIcon.doContextMenu,
        ISForageIcon_doForage         = ISForageIcon.doForage,
        ISWorldItemIcon_doPickup      = ISWorldItemIcon.doPickup,
        ISWorldItemIconTrack_doPickup = ISWorldItemIconTrack.doPickup
    }
}

function SafehouseProtectionFromForaging.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.SafehouseProtectionFromForaging
end

function SafehouseProtectionFromForaging.IsValid(square)
    if not square then
        return false
    end

    local x = square:getX()
    local y = square:getY()

    local character = getPlayer()
    local safehouse = openutils.GetSafehouseByXY(x, y)

    if safehouse and not openutils.IsUsernameMemberOfSafehouse(character:getUsername(), safehouse) then
        if openutils.IsInSafehouseSouthExtraLine(safehouse, x, y) or openutils.IsInSafehouseEastExtraLine(safehouse, x, y) then
            return true
        end

        character:Say(getText("IGUI_PlayerText_PickupUnavailable"))

        return false
    end

    return true
end

-- DoContextMenu injects custom status indicators into the player's world interaction menu.
function SafehouseProtectionFromForaging.ISBaseIcon_doContextMenu(self, context)
    if not SafehouseProtectionFromForaging.IsEnabledOnServer() then
        return SafehouseProtectionFromForaging.OriginalFunctions.ISBaseIcon_doContextMenu(self, context)
    end

    if self.isTrack then
        return
    end

    local square = self:initGridSquare()

    if SafehouseProtectionFromForaging.IsValid(square) then
        return SafehouseProtectionFromForaging.OriginalFunctions.ISBaseIcon_doContextMenu(self, context)
    end

    return false
end

function SafehouseProtectionFromForaging.ISForageIcon_doForage(self, _x, _y, _contextOption, _targetContainer)
    if not SafehouseProtectionFromForaging.IsEnabledOnServer() then
        return SafehouseProtectionFromForaging.OriginalFunctions.ISForageIcon_doForage(self, _x, _y, _contextOption, _targetContainer)
    end

    local square = self:initGridSquare()

    if SafehouseProtectionFromForaging.IsValid(square) then
        return SafehouseProtectionFromForaging.OriginalFunctions.ISForageIcon_doForage(self, _x, _y, _contextOption, _targetContainer)
    end

    return false
end

function SafehouseProtectionFromForaging.ISWorldItemIcon_doPickup(self, _x, _y, _contextOption, _targetContainer)
    if not SafehouseProtectionFromForaging.IsEnabledOnServer() then
        return SafehouseProtectionFromForaging.OriginalFunctions.ISWorldItemIcon_doPickup(self, _x, _y, _contextOption, _targetContainer)
    end

    local square = self:initGridSquare()

    if SafehouseProtectionFromForaging.IsValid(square) then
        return SafehouseProtectionFromForaging.OriginalFunctions.ISWorldItemIcon_doPickup(self, _x, _y, _contextOption, _targetContainer)
    end

    return false
end

function SafehouseProtectionFromForaging.ISWorldItemIconTrack_doPickup(self, _x, _y, _contextOption, _targetContainer)
    if not SafehouseProtectionFromForaging.IsEnabledOnServer() then
        return SafehouseProtectionFromForaging.OriginalFunctions.ISWorldItemIconTrack_doPickup(self, _x, _y, _contextOption, _targetContainer)
    end

    local square = self:initGridSquare()

    if SafehouseProtectionFromForaging.IsValid(square) then
        return SafehouseProtectionFromForaging.OriginalFunctions.ISWorldItemIconTrack_doPickup(self, _x, _y, _contextOption, _targetContainer)
    end

    return false
end

ISBaseIcon.doContextMenu = SafehouseProtectionFromForaging.ISBaseIcon_doContextMenu
ISForageIcon.doForage = SafehouseProtectionFromForaging.ISForageIcon_doForage
ISWorldItemIcon.doPickup = SafehouseProtectionFromForaging.ISWorldItemIcon_doPickup
ISWorldItemIconTrack.doPickup = SafehouseProtectionFromForaging.ISWorldItemIconTrack_doPickup
