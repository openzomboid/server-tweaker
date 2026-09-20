--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

SafehouseProtectionFromDestroy = {
    OriginalFunctions = {
        ISDestroyCursor_isValid = ISDestroyCursor.isValid
    },
}

function SafehouseProtectionFromDestroy.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.SafehouseProtectionFromDestroy
end

function SafehouseProtectionFromDestroy.ISDestroyCursor_isValid(self, square)
    local valid = SafehouseProtectionFromDestroy.OriginalFunctions.ISDestroyCursor_isValid(self, square)

    if not valid or not SafehouseProtectionFromDestroy.IsEnabledOnServer then
        return valid
    end

    if ISBuildMenu.cheat then
        return true
    end

    local x = square:getX()
    local y = square:getY()

    local safehouse = openutils.GetSafehouseByXY(x, y)

    if safehouse and not openutils.IsUsernameMemberOfSafehouse(self.character:getUsername(), safehouse) then
        if openutils.IsInSafehouseSouthExtraLine(safehouse, x, y) or openutils.IsInSafehouseEastExtraLine(safehouse, x, y) then
            return true
        end

        return false
    end

    return true
end

ISDestroyCursor.isValid = SafehouseProtectionFromDestroy.ISDestroyCursor_isValid;
