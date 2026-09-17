--
-- Copyright (c) 2026 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

-- TweakOverlayText is a global module table for managing overlay text tweaks
-- (ping, server name, and build version).
TweakOverlayText = {
    OriginalFunctions = {
        WaterMarkUI_render = WaterMarkUI.render,
        ISServerSandboxOptionsUI_onButtonApply = ISServerSandboxOptionsUI.onButtonApply
    }
}

-- IsEnabledOnServer сhecks if the TweakOverlayText module is enabled in the server's Sandbox settings.
-- @return boolean
function TweakOverlayText.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.TweakOverlayText
end

-- WaterMarkUI_render overrides the the watermark UI rendering.
-- Replaces default PZ overlay data (hides 32-player warnings/serverTime) with clean public server name,
-- custom build number, and an optimized ping display.
-- @param self WaterMarkUI
function TweakOverlayText.WaterMarkUI_render(self)
    if not TweakOverlayText.IsEnabledOnServer() then
        TweakOverlayText.OriginalFunctions.WaterMarkUI_render(self)
        return
    end

    local character = getPlayer()
    if not character then
        return
    end

    if isClient() then
        -- Hide the redundant "Review" bug-report button for players on the server
        self.revButton:setVisible(false)

        local maxY = getCore():getScreenHeight()
        local maxX = getCore():getScreenWidth()
        local statusData = getMPStatus()
        -- Strips extra text from the version string using regex (e.g., "42.20.4 somethrashtext" -> "42.20.4")
        local version = statusData.version:match("(.*) ")

        if NonPvpZone.getNonPvpZone(character:getX(), character:getY()) then
            self:drawTextRight(getText("IGUI_PvpZone_NonPvpZone"), maxX-50, maxY-120, 0, 1, 0, 1, UIFont.Small)
        end

        local tmpY = 40

        if isShowServerInfo() then
            self:drawTextRight(getServerOptions():getOption("PublicName") .. " - Build " .. version, maxX-50, maxY-tmpY, 0.8, 0.8, 0.8, 1, UIFont.Small)
            tmpY = tmpY + 30
        end

        -- Ping
        if isShowConnectionInfo() then
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

            self:drawTextRight(getText("UI_Ping", tostring(lastPing)), maxX-50, maxY-tmpY , r, g, b, 1, UIFont.Small)
            tmpY = tmpY + 25
        end
    end
end

-- ISServerSandboxOptionsUI_onButtonApply triggers watermark refreshing on-the-fly when
-- server options are updated.
-- @param self ISServerSandboxOptionsUI
function TweakOverlayText.ISServerSandboxOptionsUI_onButtonApply(self)
    TweakOverlayText.OriginalFunctions.ISServerSandboxOptionsUI_onButtonApply(self)

    if TweakOverlayText.IsEnabledOnServer then
        ISVersionWaterMark.doMsg()
    end
end

-- OnGameStart adds callback for OnGameStart global event.
function TweakOverlayText.OnGameStart()
    if SandboxVars.ServerTweaker.TweakOverlayText then
        setShowConnectionInfo(false) -- ping
        setShowServerInfo(true)
    end
end

WaterMarkUI.render = TweakOverlayText.WaterMarkUI_render
ISServerSandboxOptionsUI.onButtonApply = TweakOverlayText.ISServerSandboxOptionsUI_onButtonApply

Events.OnGameStart.Add(TweakOverlayText.OnGameStart)
