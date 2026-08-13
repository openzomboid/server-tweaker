--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakPlayerStatsUI = {
    Original = {
        canModifyThis = ISPlayerStatsUI.canModifyThis,
        updateButtons = ISPlayerStatsUI.updateButtons
    }
}

function TweakPlayerStatsUI.canModifyThis(self)
    if not SandboxVars.ServerTweaker.AllowAdminToolsForGM then
        return TweakPlayerStatsUI.Original.canModifyThis(self)
    end

    if not isClient() then return true end

    local character = getPlayer()

    local basicCondition = self.char:getCurrentSquare() and self.char:isExistInTheWorld()

    return basicCondition and openutils.HasPermission(character, "gm")
end

function TweakPlayerStatsUI.updateButtons(self)
    if not SandboxVars.ServerTweaker.AllowAdminToolsForGM then
        TweakPlayerStatsUI.Original.updateButtons(self)
        return
    end

    local buttonEnable = self:canModifyThis();
    self.addTraitBtn.enable = buttonEnable;
    self.changeProfession.enable = buttonEnable;
    self.changeForename.enable = buttonEnable;
    self.changeSurname.enable = buttonEnable;
    -- self.addGlobalXP.enable = buttonEnable;
    self.muteAllBtn.enable = buttonEnable;
    self.addXpBtn.enable = buttonEnable;
    self.addLvlBtn.enable = buttonEnable and (self.selectedPerk ~= nil)
    self.loseLvlBtn.enable = buttonEnable and (self.selectedPerk ~= nil)
    self.userlogBtn.enable = buttonEnable;
    self.manageInvBtn.enable = buttonEnable;
    self.warningPointsBtn.enable = buttonEnable;
    self.weightBtn.enable = buttonEnable;
    self.changeAccessLvlBtn.enable = (self.admin:getAccessLevel() == "Admin" or self.admin:getAccessLevel() == "Moderator") and self:canModifyThis();
    self.changeUsernameBtn.enable = buttonEnable;
    for _, image in ipairs(self.traits) do
        self.traitsRemoveButtons[image.label].enable = buttonEnable;
    end
end

ISPlayerStatsUI.canModifyThis = TweakPlayerStatsUI.canModifyThis;
ISPlayerStatsUI.updateButtons = TweakPlayerStatsUI.updateButtons;
