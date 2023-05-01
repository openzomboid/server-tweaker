--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

if not isClient() then return end

TweakISAdminPowerUI = {
    Original = {
        addOption = ISAdminPowerUI.addOption,
        addAdminPowerOptions = ISAdminPowerUI.addAdminPowerOptions,
        onClick = ISAdminPowerUI.onClick,
    }
}

TweakISAdminPowerUI.addAdminPowerOptions = function(self)
    local setFunction = {}

    if SandboxVars.ServerTweaker.SaveAdminPower then
        self.setFunction = {}

        self:addOption("Show admin tag", ClientTweaker.AdminOptions.GetBool("ShowAdminTag"), function(self, selected)
            ClientTweaker.AdminOptions.SetBool("ShowAdminTag", selected);
        end);

        setFunction = self.setFunction
    end

    TweakISAdminPowerUI.Original.addAdminPowerOptions(self)

    if SandboxVars.ServerTweaker.SaveAdminPower then
        for i, v in pairs(self.setFunction) do
            setFunction[i] = v
        end

        self.setFunction = setFunction
    end
end

TweakISAdminPowerUI.onClick = function(self, button)
    TweakISAdminPowerUI.Original.onClick(self, button)

    if SandboxVars.ServerTweaker.SaveAdminPower then
        self.player:setShowAdminTag(ClientTweaker.AdminOptions.GetBool("ShowAdminTag"));
        sendPlayerExtraInfo(self.player)
    end
end

TweakISAdminPowerUI.addOption = function(self, text, selected, setFunction)
    if SandboxVars.ServerTweaker.SaveAdminPower then
        local originalFunc = setFunction

        setFunction = function(self1, selected1)
            originalFunc(self1, selected1)

            if text == "Invisible" then
                ClientTweaker.AdminOptions.SetBool("Invisible", selected1);
            end

            if text == "God mode" then
                ClientTweaker.AdminOptions.SetBool("GodMode", selected1);
            end

            if text == "Ghost mode" then
                ClientTweaker.AdminOptions.SetBool("GhostMode", selected1);
            end

            if text == "No Clip" then
                ClientTweaker.AdminOptions.SetBool("NoClip", selected1);
            end

            if text == "Timed Action Instant" then
                ClientTweaker.AdminOptions.SetBool("TimedActionInstantCheat", selected1);
            end

            if text == "Unlimited Carry" then
                ClientTweaker.AdminOptions.SetBool("UnlimitedCarry", selected1);
            end

            if text == "Unlimited Endurance" then
                ClientTweaker.AdminOptions.SetBool("UnlimitedEndurance", selected1);
            end

            if text == "Fast Move" then
                ClientTweaker.AdminOptions.SetBool("FastMove", selected1);
            end

            if text == getText("IGUI_AdminPanel_BuildCheat") then
                ClientTweaker.AdminOptions.SetBool("BuildCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_FarmingCheat") then
                ClientTweaker.AdminOptions.SetBool("FarmingCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_HealthCheat") then
                ClientTweaker.AdminOptions.SetBool("HealthCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_MechanicsCheat") then
                ClientTweaker.AdminOptions.SetBool("MechanicsCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_MoveableCheat") then
                ClientTweaker.AdminOptions.SetBool("MovablesCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_CanSeeAll") then
                ClientTweaker.AdminOptions.SetBool("CanSeeAll", selected1);
            end

            if text == getText("IGUI_AdminPanel_NetworkTeleportEnabled") then
                ClientTweaker.AdminOptions.SetBool("NetworkTeleportEnabled", selected1);
            end

            if text == getText("IGUI_AdminPanel_CanHearAll") then
                ClientTweaker.AdminOptions.SetBool("CanHearAll", selected1);
            end

            if text == getText("IGUI_AdminPanel_ZombiesDontAttack") then
                ClientTweaker.AdminOptions.SetBool("ZombiesDontAttack", selected1);
            end

            if text == getText("IGUI_AdminPanel_ShowMPInfos") then
                ClientTweaker.AdminOptions.SetBool("ShowMPInfos", selected1);
            end

            if text == "Brush tool" then
                ClientTweaker.AdminOptions.SetBool("BrushTool", selected1);
            end
        end
    end

    TweakISAdminPowerUI.Original.addOption(self, text, selected, setFunction)
end

ISAdminPowerUI.addAdminPowerOptions = TweakISAdminPowerUI.addAdminPowerOptions;
ISAdminPowerUI.onClick = TweakISAdminPowerUI.onClick;
ISAdminPowerUI.addOption = TweakISAdminPowerUI.addOption;
