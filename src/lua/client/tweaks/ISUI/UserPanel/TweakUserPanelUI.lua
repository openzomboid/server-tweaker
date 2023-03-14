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

-- create overrides the original ISUserPanelUI:create function to remove
-- server options button from client menu.
TweakUserPanelUI.create = function(self)
    TweakUserPanelUI.Original.create(self)

    self.serverOptionBtn.enable = false;
    self.showConnectionInfo.enable = false;
    self.showServerInfo.enable = false;

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

function TweakUserPanelUI:onHighlightSafehouse(option, enabled)
    ClientTweaker.Options.SetBool("highlight_safehouse", enabled);
end

function TweakUserPanelUI:onShowPingInfo(option, enabled)
    TweakUserPanelUI.Original.onShowPingInfo(self, option, enabled)

    ClientTweaker.Options.SetBool("show_ping", enabled);
end

ISUserPanelUI.create = TweakUserPanelUI.create;
ISUserPanelUI.onShowPingInfo = TweakUserPanelUI.onShowPingInfo;
