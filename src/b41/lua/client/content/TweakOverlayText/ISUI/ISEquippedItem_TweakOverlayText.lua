--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

ISEquippedItem_TweakOverlayText = {
    Original = {
        prerender = ISEquippedItem.prerender,
    }
}

-- prerender rewrites original ISEquippedItem_TweakOverlayText.prerender function.
-- Adds server public name, hides strange serverTime and 32 players warning.
ISEquippedItem_TweakOverlayText.prerender = function(self)
    if not SandboxVars.ServerTweaker.TweakOverlayText then
        ISEquippedItem_TweakOverlayText.Original.prerender(self)
        return
    end

    -- Hack for clear text.
    local drawTextRight = self.drawTextRight
    self.drawTextRight = function() end
    pcall(ISEquippedItem_TweakOverlayText.Original.prerender, self)
    self.drawTextRight = drawTextRight

    if isClient() then
        local maxY = getCore():getScreenHeight();
        local maxX = getCore():getScreenWidth();
        local statusData = getMPStatus()

        if NonPvpZone.getNonPvpZone(self.chr:getX(), self.chr:getY()) then
            self:drawTextRight(getText("IGUI_PvpZone_NonPvpZone"), maxX-50, maxY-80, 0, 1, 0, 1, UIFont.Small);
        end

        local tmpY = 40

        if isShowConnectionInfo() then
            self:drawTextRight(getServerOptions():getOption("PublicName") .. " - Build " .. statusData.version, maxX-50, maxY-40, 0.8, 0.8, 0.8, 1, UIFont.NewMedium);
            tmpY = tmpY + 20
        end

        if isShowPingInfo() then
            local lastPing = tonumber(statusData.lastPing)
            local r = 0.8
            local g = 0.8
            local b = 0.8
            if lastPing > 300 then
                r = 1
                g = 0.5
                b = 0.2
            elseif lastPing < 0 then
                lastPing = 0
                r = 0.5
                g = 0.5
                b = 0.5
            end
            self:drawTextRight(getText("UI_Ping", tostring(lastPing)), maxX-50, maxY-tmpY , r, g, b, 1, UIFont.NewMedium);
            tmpY = tmpY + 20
        end
    end
end

ISEquippedItem.prerender = ISEquippedItem_TweakOverlayText.prerender;
