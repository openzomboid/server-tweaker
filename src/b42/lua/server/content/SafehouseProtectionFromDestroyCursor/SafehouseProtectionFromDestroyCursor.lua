--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

SafehouseProtectionFromDestroyCursor = {
    OriginalFunctions = {
        ISDestroyCursor_isValid = ISDestroyCursor.isValid
    },
}

function SafehouseProtectionFromDestroyCursor.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.SafehouseProtectionFromDestroyCursor
end

function SafehouseProtectionFromDestroyCursor.ISDestroyCursor_isValid(self, square)
    local valid = SafehouseProtectionFromDestroyCursor.OriginalFunctions.ISDestroyCursor_isValid(self, square)

    if not valid or not SafehouseProtectionFromDestroyCursor.IsEnabledOnServer then
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

ISDestroyCursor.isValid = SafehouseProtectionFromDestroyCursor.ISDestroyCursor_isValid;
