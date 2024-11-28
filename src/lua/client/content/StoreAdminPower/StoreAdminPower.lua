--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

StoreAdminPower = {
    AdminOptions = OpenOptions:new("admin-options", {
        ["ShowAdminTag"] = {type = "bool", value = "true"},
        ["Invisible"] = {type = "bool", value = "true"},
        ["GodMode"] = {type = "bool", value = "true"},
        ["GhostMode"] = {type = "bool", value = "true"},
        ["NoClip"] = {type = "bool", value = "false"},
        ["TimedActionInstantCheat"] = {type = "bool", value = "false"},
        ["UnlimitedCarry"] = {type = "bool", value = "false"},
        ["UnlimitedEndurance"] = {type = "bool", value = "false"},
        ["FastMove"] = {type = "bool", value = "false"},
        ["BuildCheat"] = {type = "bool", value = "false"},
        ["FarmingCheat"] = {type = "bool", value = "false"},
        ["HealthCheat"] = {type = "bool", value = "false"},
        ["MechanicsCheat"] = {type = "bool", value = "false"},
        ["MovablesCheat"] = {type = "bool", value = "false"},
        ["CanSeeAll"] = {type = "bool", value = "false"},
        ["NetworkTeleportEnabled"] = {type = "bool", value = "false"},
        ["CanHearAll"] = {type = "bool", value = "false"},
        ["ZombiesDontAttack"] = {type = "bool", value = "false"},
        ["ShowMPInfos"] = {type = "bool", value = "false"},
        ["BrushTool"] = {type = "bool", value = "false"},
    })
}

function StoreAdminPower.SetAdminPower()
    if not SandboxVars.ServerTweaker.SaveAdminPower then
        return
    end

    local character = getPlayer();

    if isClient() and character and openutils.HasPermission(character, "observer") then
        character:setInvisible(StoreAdminPower.AdminOptions.GetBool("Invisible"));
        character:setGodMod(StoreAdminPower.AdminOptions.GetBool("GodMode"));
        character:setGhostMode(StoreAdminPower.AdminOptions.GetBool("GhostMode"));
        character:setNoClip(StoreAdminPower.AdminOptions.GetBool("NoClip"));
        character:setTimedActionInstantCheat(StoreAdminPower.AdminOptions.GetBool("TimedActionInstantCheat"));
        character:setUnlimitedCarry(StoreAdminPower.AdminOptions.GetBool("UnlimitedCarry"));
        character:setUnlimitedEndurance(StoreAdminPower.AdminOptions.GetBool("UnlimitedEndurance"));

        ISFastTeleportMove.cheat = StoreAdminPower.AdminOptions.GetBool("FastMove");

        ISBuildMenu.cheat = StoreAdminPower.AdminOptions.GetBool("BuildCheat");
        character:setBuildCheat(StoreAdminPower.AdminOptions.GetBool("BuildCheat"));

        ISFarmingMenu.cheat = StoreAdminPower.AdminOptions.GetBool("FarmingCheat");
        character:setFarmingCheat(StoreAdminPower.AdminOptions.GetBool("FarmingCheat"));

        ISHealthPanel.cheat = StoreAdminPower.AdminOptions.GetBool("HealthCheat");
        character:setHealthCheat(StoreAdminPower.AdminOptions.GetBool("HealthCheat"));

        ISVehicleMechanics.cheat = StoreAdminPower.AdminOptions.GetBool("MechanicsCheat");
        character:setMechanicsCheat(StoreAdminPower.AdminOptions.GetBool("MechanicsCheat"));

        ISMoveableDefinitions.cheat = StoreAdminPower.AdminOptions.GetBool("MovablesCheat");
        character:setMovablesCheat(StoreAdminPower.AdminOptions.GetBool("MovablesCheat"));

        character:setNetworkTeleportEnabled(StoreAdminPower.AdminOptions.GetBool("NetworkTeleportEnabled"));
        character:setCanSeeAll(StoreAdminPower.AdminOptions.GetBool("CanSeeAll"));
        character:setCanHearAll(StoreAdminPower.AdminOptions.GetBool("CanHearAll"));
        character:setZombiesDontAttack(StoreAdminPower.AdminOptions.GetBool("ZombiesDontAttack"));
        character:setShowMPInfos(StoreAdminPower.AdminOptions.GetBool("ShowMPInfos"));

        BrushToolManager.cheat = StoreAdminPower.AdminOptions.GetBool("BrushTool");

        character:setShowAdminTag(StoreAdminPower.AdminOptions.GetBool("ShowAdminTag"));

        sendPlayerExtraInfo(character);
    end
end

-- OnCreatePlayer adds callback for player OnCreatePlayer event.
function StoreAdminPower.OnCreatePlayer(id)
    if not SandboxVars.ServerTweaker.SaveAdminPower then
        return
    end

    local ticker = {}

    ticker.OnTick = function()
        local character = getPlayer();

        if character then
            Events.OnTick.Remove(ticker.OnTick);
            StoreAdminPower.SetAdminPower();
        end
    end

    Events.OnTick.Add(ticker.OnTick);
end

Events.OnCreatePlayer.Add(StoreAdminPower.OnCreatePlayer);
