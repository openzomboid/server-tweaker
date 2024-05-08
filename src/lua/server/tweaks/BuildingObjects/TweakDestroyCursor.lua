--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakDestroyCursor = {
    Original = {
        isValid = ISDestroyCursor.isValid
    },
}

function TweakDestroyCursor.isValid(self, square)
    local valid = TweakDestroyCursor.Original.isValid(self, square)
    if not valid then
        return valid
    end

    if ISBuildMenu.cheat then
        return true
    end

    local x = square:getX()
    local y = square:getY()

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and not openutils.IsPlayerMemmberOfSafehouse(self.character, safehouse) then
        if openutils.IsInSafehouseSouthExtraLine(safehouse, x, y) or openutils.IsInSafehouseEastExtraLine(safehouse, x, y) then
            return true
        end

        return false
    end

    return true
end

ISDestroyCursor.isValid = TweakDestroyCursor.isValid;
