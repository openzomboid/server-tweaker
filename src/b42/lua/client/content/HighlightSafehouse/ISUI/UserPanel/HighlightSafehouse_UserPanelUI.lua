--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

HighlightSafehouse_UserPanelUI = {
    OriginalFunctions = {
        ISUserPanelUI_create = ISUserPanelUI.create
    }
}

-- create overrides the original ISUserPanelUI:create function.
-- Adds server HighlightSafehouse options to client menu.
HighlightSafehouse_UserPanelUI.create = function(self)
    HighlightSafehouse_UserPanelUI.OriginalFunctions.ISUserPanelUI_create(self)

    if not SandboxVars.ServerTweaker.HighlightSafehouse then
        return
    end

    local enabled = HighlightSafehouse.ClientOptionEnabled
    if SandboxVars.ServerTweaker.SaveClientOptions and ClientTweaker.Options then
        enabled = ClientTweaker.Options.GetBool("highlight_safehouse")
    end

    local btnWid = UI_BORDER_SPACING*2+getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_UserPanel_ShowConnectionInfo")) + BUTTON_HGT
    local y = self.cancel.y

    self.highlightSafehouse = ISTickBox:new(self.factionBtn.x, y, btnWid, BUTTON_HGT, getText("IGUI_UserPanel_HighlightSafehouse"), self, HighlightSafehouse_UserPanelUI.onHighlightSafehouse)
    self.highlightSafehouse:initialise()
    self.highlightSafehouse:instantiate()
    self.highlightSafehouse.selected[1] = enabled
    self.highlightSafehouse:addOption(getText("IGUI_UserPanel_HighlightSafehouse"))
    self.highlightSafehouse.enable = SandboxVars.ServerTweaker.HighlightSafehouse
    self:addChild(self.highlightSafehouse)
    y = y + BUTTON_HGT + UI_BORDER_SPACING

    if self.cancel and self.cancel.setY then
        self.cancel:setY(y)
    end

    local width = 0
    for _,child in pairs(self:getChildren()) do
        width = math.max(width, child:getWidth())
    end
    for _,child in pairs(self:getChildren()) do
        child:setWidth(width)
    end

    self:setWidth(UI_BORDER_SPACING*2 + 2 + btnWid)
    self:setHeight(self.cancel.y + BUTTON_HGT + UI_BORDER_SPACING + 1)
end

function HighlightSafehouse_UserPanelUI:onHighlightSafehouse(option, enabled)
    HighlightSafehouse.ClientOptionEnabled = enabled

    if SandboxVars.ServerTweaker.SaveClientOptions then
        ClientTweaker.Options.SetBool("highlight_safehouse", enabled)
    end
end

ISUserPanelUI.create = HighlightSafehouse_UserPanelUI.create
