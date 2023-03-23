--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local FLOOR_HIGHLIGHT_COLOR = ColorInfo.new(0, 1, 0, 1.0);

TweakEquippedItem = {
    Original = {
        prerender = ISEquippedItem.prerender,
    }
}

-- prerender rewrites original TweakEquippedItem.prerender function.
-- Adds server public name, hides strange serverTime and 32 players warning.
TweakEquippedItem.prerender = function(self)
    if not SandboxVars.ServerTweaker.TweakOverlayText then
        TweakEquippedItem.Original.prerender(self)
        return
    end

    local drawTextRight = self.drawTextRight
    self.drawTextRight = function() end
    pcall(TweakEquippedItem.Original.prerender, self)
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
            self:drawTextRight(getServerOptions():getOption("PublicName").." - Build "..statusData.version, maxX-50, maxY-40, 0.8, 0.8, 0.8, 1, UIFont.NewMedium);
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

-- ticks adds ticker for highlight players safehouses.
TweakEquippedItem.ticks = function(ticks)
    local character = getPlayer()
    if not character then
        return
    end

    if not SandboxVars.ServerTweaker.HighlightSafehouse then
        return
    end

    if ClientTweaker.Options.GetBool("highlight_safehouse") == false then
        return
    end

    local storage = ClientTweaker.Storage

    if storage then
        local safehouses = storage.GetSafehouses()

        if safehouses then
            local cell = getCell()

            for _, safehouse in pairs(safehouses) do
                local x1 = safehouse:getX()
                local x2 = safehouse:getX() + safehouse:getW() - 1
                local y1 = safehouse:getY()
                local y2 = safehouse:getY() + safehouse:getH() - 1

                for x = x1, x2 do
                    for y = y1, y2 do
                        local sq = cell:getGridSquare(x, y, 0)
                        if sq and sq:getFloor() then
                            local obj = sq:getFloor()
                            obj:setHighlighted(true)
                            obj:setHighlightColor(FLOOR_HIGHLIGHT_COLOR);
                        end
                    end
                end
            end
        end
    end
end

ISEquippedItem.prerender = TweakEquippedItem.prerender;
Events.OnRenderTick.Add(TweakEquippedItem.ticks);
