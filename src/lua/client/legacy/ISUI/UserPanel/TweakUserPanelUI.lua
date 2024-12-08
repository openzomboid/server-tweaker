--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);

TweakUserPanelUI = {
    Original = {
        create = ISUserPanelUI.create,
        onShowPingInfo = ISUserPanelUI.onShowPingInfo
    }
}

-- create overrides the original ISUserPanelUI:create function.
-- Disables server options button in client menu.
-- Disables showConnectionInfo and showServerInfo in client menu.
-- Adds server HighlightSafehouse options to client menu.
TweakUserPanelUI.create = function(self)
    TweakUserPanelUI.Original.create(self)

    -- Disable server options button.
    if SandboxVars.ServerTweaker.HideServerOptionsFromPlayers then
        self.serverOptionBtn.enable = false;
    end

    -- Disable tickets button.
    if SandboxVars.ServerTweaker.HideTicketsFromPlayers then
        self.ticketsBtn.enable = false;
    end

    -- Disable showConnectionInfo and showServerInfo.
    if SandboxVars.ServerTweaker.PinOverlayServerInfoText then
        self.showConnectionInfo.enable = false;
        self.showServerInfo.enable = false;
    end

    -- Add server HighlightSafehouse options to client menu.
    if SandboxVars.ServerTweaker.HighlightSafehouse then
        local btnWid = 150
        local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
        local y = 70 + ((btnHgt + 5) * 3)

        self.highlightSafehouse = ISTickBox:new(10 + btnWid + 20, y, btnWid, btnHgt, getText("IGUI_UserPanel_HighlightSafehouse"), self, TweakUserPanelUI.onHighlightSafehouse);
        self.highlightSafehouse:initialise();
        self.highlightSafehouse:instantiate();
        self.highlightSafehouse.selected[1] = ClientTweaker.Options.GetBool("highlight_safehouse");
        self.highlightSafehouse:addOption(getText("IGUI_UserPanel_HighlightSafehouse"));
        self.highlightSafehouse.enable = SandboxVars.ServerTweaker.HighlightSafehouse;
        self:addChild(self.highlightSafehouse);
        y = y + btnHgt + 5;
    end
end

function TweakUserPanelUI:onHighlightSafehouse(option, enabled)
    if SandboxVars.ServerTweaker.SaveClientOptions then
        ClientTweaker.Options.SetBool("highlight_safehouse", enabled);
    end
end

function TweakUserPanelUI:onShowPingInfo(option, enabled)
    TweakUserPanelUI.Original.onShowPingInfo(self, option, enabled)

    if SandboxVars.ServerTweaker.SaveClientOptions then
        ClientTweaker.Options.SetBool("show_ping", enabled);
    end
end

ISUserPanelUI.create = TweakUserPanelUI.create;
ISUserPanelUI.onShowPingInfo = TweakUserPanelUI.onShowPingInfo;
