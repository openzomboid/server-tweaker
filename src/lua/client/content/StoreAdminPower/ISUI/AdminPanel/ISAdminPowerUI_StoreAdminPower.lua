--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

if not isClient() then return end

require 'StoreAdminPower/StoreAdminPower'

ISAdminPowerUI_StoreAdminPower = {
    Original = {
        addOption = ISAdminPowerUI.addOption,
        addAdminPowerOptions = ISAdminPowerUI.addAdminPowerOptions,
        onClick = ISAdminPowerUI.onClick,
    }
}

ISAdminPowerUI_StoreAdminPower.addAdminPowerOptions = function(self)
    local setFunction = {}

    if SandboxVars.ServerTweaker.SaveAdminPower then
        self.setFunction = {}

        self:addOption("Show admin tag", StoreAdminPower.AdminOptions.GetBool("ShowAdminTag"), function(self, selected)
            StoreAdminPower.AdminOptions.SetBool("ShowAdminTag", selected);
        end);

        setFunction = self.setFunction
    end

    ISAdminPowerUI_StoreAdminPower.Original.addAdminPowerOptions(self)

    if SandboxVars.ServerTweaker.SaveAdminPower then
        for i, v in pairs(self.setFunction) do
            setFunction[i] = v
        end

        self.setFunction = setFunction
    end
end

ISAdminPowerUI_StoreAdminPower.onClick = function(self, button)
    ISAdminPowerUI_StoreAdminPower.Original.onClick(self, button)

    if SandboxVars.ServerTweaker.SaveAdminPower then
        self.player:setShowAdminTag(StoreAdminPower.AdminOptions.GetBool("ShowAdminTag"));
        sendPlayerExtraInfo(self.player)
    end
end

ISAdminPowerUI_StoreAdminPower.addOption = function(self, text, selected, setFunction)
    if SandboxVars.ServerTweaker.SaveAdminPower then
        local originalFunc = setFunction

        setFunction = function(self1, selected1)
            originalFunc(self1, selected1)

            if text == "Invisible" then
                StoreAdminPower.AdminOptions.SetBool("Invisible", selected1);
            end

            if text == "God mode" then
                StoreAdminPower.AdminOptions.SetBool("GodMode", selected1);
            end

            if text == "Ghost mode" then
                StoreAdminPower.AdminOptions.SetBool("GhostMode", selected1);
            end

            if text == "No Clip" then
                StoreAdminPower.AdminOptions.SetBool("NoClip", selected1);
            end

            if text == "Timed Action Instant" then
                StoreAdminPower.AdminOptions.SetBool("TimedActionInstantCheat", selected1);
            end

            if text == "Unlimited Carry" then
                StoreAdminPower.AdminOptions.SetBool("UnlimitedCarry", selected1);
            end

            if text == "Unlimited Endurance" then
                StoreAdminPower.AdminOptions.SetBool("UnlimitedEndurance", selected1);
            end

            if text == "Fast Move" then
                StoreAdminPower.AdminOptions.SetBool("FastMove", selected1);
            end

            if text == getText("IGUI_AdminPanel_BuildCheat") then
                StoreAdminPower.AdminOptions.SetBool("BuildCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_FarmingCheat") then
                StoreAdminPower.AdminOptions.SetBool("FarmingCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_HealthCheat") then
                StoreAdminPower.AdminOptions.SetBool("HealthCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_MechanicsCheat") then
                StoreAdminPower.AdminOptions.SetBool("MechanicsCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_MoveableCheat") then
                StoreAdminPower.AdminOptions.SetBool("MovablesCheat", selected1);
            end

            if text == getText("IGUI_AdminPanel_CanSeeAll") then
                StoreAdminPower.AdminOptions.SetBool("CanSeeAll", selected1);
            end

            if text == getText("IGUI_AdminPanel_NetworkTeleportEnabled") then
                StoreAdminPower.AdminOptions.SetBool("NetworkTeleportEnabled", selected1);
            end

            if text == getText("IGUI_AdminPanel_CanHearAll") then
                StoreAdminPower.AdminOptions.SetBool("CanHearAll", selected1);
            end

            if text == getText("IGUI_AdminPanel_ZombiesDontAttack") then
                StoreAdminPower.AdminOptions.SetBool("ZombiesDontAttack", selected1);
            end

            if text == getText("IGUI_AdminPanel_ShowMPInfos") then
                StoreAdminPower.AdminOptions.SetBool("ShowMPInfos", selected1);
            end

            if text == "Brush tool" then
                StoreAdminPower.AdminOptions.SetBool("BrushTool", selected1);
            end
        end
    end

    ISAdminPowerUI_StoreAdminPower.Original.addOption(self, text, selected, setFunction)
end

ISAdminPowerUI.addAdminPowerOptions = ISAdminPowerUI_StoreAdminPower.addAdminPowerOptions;
ISAdminPowerUI.onClick = ISAdminPowerUI_StoreAdminPower.onClick;
ISAdminPowerUI.addOption = ISAdminPowerUI_StoreAdminPower.addOption;
