--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

MainOptions_FixOptionShowYourUsername = {
    Original = {
        addPage = MainOptions.addPage
    }
}

MainOptions_FixOptionShowYourUsername.addPage = function(self, name)
    MainOptions_FixOptionShowYourUsername.Original.addPage(self, name)

    if not SandboxVars.ServerTweaker.FixOptionShowYourUsername then
        return
    end

    if name == getText("UI_optionscreen_multiplayer") then
        local addChild = self.mainPanel.addChild

        self.mainPanel.addChild = function(self, element)
            if element.tooltip == getText("UI_optionscreen_showUsernameTooltip") then
                return
            end

            addChild(self, element)
        end
    end
end

MainOptions.addPage = MainOptions_FixOptionShowYourUsername.addPage;
