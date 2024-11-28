--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);

ISAdminPanelUI_AddDatabaseButton = {
    Original = {
        create = ISAdminPanelUI.create
    }
}

-- create overrides the original ISAdminPanelUI:create() function.
ISAdminPanelUI_AddDatabaseButton.create = function(self)
    ISAdminPanelUI_AddDatabaseButton.Original.create(self)

    local btnWid = 150
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local btnGapY = 5
    local y = 190

    -- getText("IGUI_AdminPanel_SeeDB")
    self.opendbBtn = ISButton:new(10 + btnWid + 20, y, btnWid, btnHgt, "See OpenDB", self, ISAdminPanelUI_AddDatabaseButton.onOptionMouseDown);
    self.opendbBtn.internal = "OPENDB";
    self.opendbBtn:initialise();
    self.opendbBtn:instantiate();
    self.opendbBtn.borderColor = self.buttonBorderColor;
    self:addChild(self.opendbBtn);

    if getAccessLevel() == "observer" then
        self.opendbBtn.enable = false;
    end

    y = y + btnHgt + btnGapY;

    self:updateButtons();
end

function ISAdminPanelUI_AddDatabaseButton:onOptionMouseDown(button, x, y)
    if button.internal == "OPENDB" then
        local character = getPlayer()

        if DatabaseListViewer.instance then
            DatabaseListViewer.instance:closeSelf()
        end

        local modal = DatabaseListViewer:new(50, 200, 1200, 650)
        modal:initialise();
        modal:addToUIManager();

        DatabaseListViewer.instance:refresh();
    end

    self:updateButtons();
end

ISAdminPanelUI.create = ISAdminPanelUI_AddDatabaseButton.create;
