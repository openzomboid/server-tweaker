--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakOverlayText = {
    OriginalFunctions = {
        WaterMarkUI_render = WaterMarkUI.render
    }
}

-- Adds server public name, hides strange serverTime and 32 players warning.
function TweakOverlayText.WaterMarkUI_render(self)
    if not SandboxVars.ServerTweaker.TweakOverlayText then
        TweakOverlayText.OriginalFunctions.WaterMarkUI_render(self)
        return
    end

    local character = getPlayer()
    if not character then
        return
    end

    if isClient() then
        self.revButton:setVisible(false)

        local maxY = getCore():getScreenHeight()
        local maxX = getCore():getScreenWidth()
        local statusData = getMPStatus()

        if NonPvpZone.getNonPvpZone(character:getX(), character:getY()) then
            self:drawTextRight(getText("IGUI_PvpZone_NonPvpZone"), maxX-50, maxY-120, 0, 1, 0, 1, UIFont.Small)
        end

        local tmpY = 40

        if isShowConnectionInfo() then
            self:drawTextRight(getServerOptions():getOption("PublicName") .. " - Build " .. statusData.version, maxX-50, maxY-tmpY, 0.8, 0.8, 0.8, 1, UIFont.Small)
            tmpY = tmpY + 25
        end

        if isShowServerInfo() then
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
            self:drawTextRight(getText("UI_Ping", tostring(lastPing)), maxX-50, maxY-tmpY , r, g, b, 1, UIFont.Small);
            tmpY = tmpY + 25
        end
    end
end

-- OnGameStart adds callback for OnGameStart global event.
function TweakOverlayText.OnGameStart()
    if SandboxVars.ServerTweaker.TweakOverlayText then
        setShowConnectionInfo(true)
        setShowServerInfo(true)
    end
end

WaterMarkUI.render = TweakOverlayText.WaterMarkUI_render

Events.OnGameStart.Add(TweakOverlayText.OnGameStart)
