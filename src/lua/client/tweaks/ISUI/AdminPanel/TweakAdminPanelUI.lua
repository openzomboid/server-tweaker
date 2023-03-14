--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakAdminPanelUI = {
    Original = {
        create = ISAdminPanelUI.create,
        updateButtons = ISAdminPanelUI.updateButtons
    }
}

-- create overrides the original ISAdminPanelUI:create() function.
-- Allows to create safehouse by Moderator.
TweakAdminPanelUI.create = function(self)
    TweakAdminPanelUI.Original.create(self)

    if getAccessLevel() == "moderator" then
        self.safezoneBtn.enable = true;
    end
end

-- updateButtons overrides the original ISAdminPanelUI:updateButtons() function.
-- Allows to create safehouse by Moderator.
TweakAdminPanelUI.updateButtons = function(self)
    TweakAdminPanelUI.Original.updateButtons(self)

    if getAccessLevel() == "moderator" then
        self.safezoneBtn.enable = true;
    end
end

ISAdminPanelUI.create = TweakAdminPanelUI.create;
ISAdminPanelUI.updateButtons = TweakAdminPanelUI.updateButtons;
