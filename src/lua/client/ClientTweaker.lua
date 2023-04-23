--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

ClientTweaker = {
    Version = openutils.Version,
    Options = OpenOptions:new("client-options", {
        ["highlight_safehouse"] = {type = "bool", value = "false"},
        ["show_ping"] = {type = "bool", value = "true"},
    }),
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
    }),
    Items = OpenItemTweaker:new(),
    Storage = nil,
}

-- TweakFirearmsSoundRadius returns SoundRadius to 41.56 values for firearms
-- if enabled.
local function TweakFirearmsSoundRadius()
    if not SandboxVars.ServerTweaker.TweakFirearmsSoundRadius then
        return
    end

    ClientTweaker.Items.Add("Base.Pistol3", "SoundRadius", "100");
    ClientTweaker.Items.Add("Base.Pistol2", "SoundRadius", "70");
    ClientTweaker.Items.Add("Base.Revolver_Short", "SoundRadius", "30");
    ClientTweaker.Items.Add("Base.Revolver", "SoundRadius", "70");
    ClientTweaker.Items.Add("Base.Pistol", "SoundRadius", "50");
    ClientTweaker.Items.Add("Base.Revolver_Long", "SoundRadius", "120");

    ClientTweaker.Items.Add("Base.DoubleBarrelShotgun", "SoundRadius", "200");
    ClientTweaker.Items.Add("Base.DoubleBarrelShotgunSawnoff", "SoundRadius", "250");
    ClientTweaker.Items.Add("Base.Shotgun", "SoundRadius", "200");
    ClientTweaker.Items.Add("Base.ShotgunSawnoff", "SoundRadius", "250");

    ClientTweaker.Items.Add("Base.AssaultRifle2", "SoundRadius", "90");
    ClientTweaker.Items.Add("Base.AssaultRifle", "SoundRadius", "100");
    ClientTweaker.Items.Add("Base.VarmintRifle", "SoundRadius", "150");
    ClientTweaker.Items.Add("Base.HuntingRifle", "SoundRadius", "150");
end

local function SetAdminPower()
    if not SandboxVars.ServerTweaker.SaveAdminPower then
        return
    end

    local character = getPlayer();

    if isClient() and character and openutils.HasPermission(character, "observer") then
        character:setInvisible(ClientTweaker.AdminOptions.GetBool("Invisible"));
        character:setGodMod(ClientTweaker.AdminOptions.GetBool("GodMode"));
        character:setGhostMode(ClientTweaker.AdminOptions.GetBool("GhostMode"));
        character:setNoClip(ClientTweaker.AdminOptions.GetBool("NoClip"));
        character:setTimedActionInstantCheat(ClientTweaker.AdminOptions.GetBool("TimedActionInstantCheat"));
        character:setUnlimitedCarry(ClientTweaker.AdminOptions.GetBool("UnlimitedCarry"));
        character:setUnlimitedEndurance(ClientTweaker.AdminOptions.GetBool("UnlimitedEndurance"));

        ISFastTeleportMove.cheat = ClientTweaker.AdminOptions.GetBool("FastMove");

        ISBuildMenu.cheat = ClientTweaker.AdminOptions.GetBool("BuildCheat");
        character:setBuildCheat(ClientTweaker.AdminOptions.GetBool("BuildCheat"));

        ISFarmingMenu.cheat = ClientTweaker.AdminOptions.GetBool("FarmingCheat");
        character:setFarmingCheat(ClientTweaker.AdminOptions.GetBool("FarmingCheat"));

        ISHealthPanel.cheat = ClientTweaker.AdminOptions.GetBool("HealthCheat");
        character:setHealthCheat(ClientTweaker.AdminOptions.GetBool("HealthCheat"));

        ISVehicleMechanics.cheat = ClientTweaker.AdminOptions.GetBool("MechanicsCheat");
        character:setMechanicsCheat(ClientTweaker.AdminOptions.GetBool("MechanicsCheat"));

        ISMoveableDefinitions.cheat = ClientTweaker.AdminOptions.GetBool("MovablesCheat");
        character:setMovablesCheat(ClientTweaker.AdminOptions.GetBool("MovablesCheat"));

        character:setNetworkTeleportEnabled(ClientTweaker.AdminOptions.GetBool("NetworkTeleportEnabled"));
        character:setCanSeeAll(ClientTweaker.AdminOptions.GetBool("CanSeeAll"));
        character:setCanHearAll(ClientTweaker.AdminOptions.GetBool("CanHearAll"));
        character:setZombiesDontAttack(ClientTweaker.AdminOptions.GetBool("ZombiesDontAttack"));
        character:setShowMPInfos(ClientTweaker.AdminOptions.GetBool("ShowMPInfos"));

        BrushToolManager.cheat = ClientTweaker.AdminOptions.GetBool("BrushTool");

        character:setShowAdminTag(ClientTweaker.AdminOptions.GetBool("ShowAdminTag"));

        sendPlayerExtraInfo(character);
    end
end

-- OnGameStart adds callback for OnGameStart global event.
local function OnGameStart()
    if SandboxVars.ServerTweaker.DisableAimOutline then
        getCore():setOptionAimOutline(1);
    end

    if SandboxVars.ServerTweaker.AddClientCache then
        local player = getPlayer();
        if player then
            ClientTweaker.Storage = OpenUserStorage:new(player:getUsername())
        end
    end

    if SandboxVars.ServerTweaker.TweakOverlayText then
        setShowConnectionInfo(true);
        setShowServerInfo(false);
    end

    if SandboxVars.ServerTweaker.SaveClientOptions then
        setShowPingInfo(ClientTweaker.Options.GetBool("show_ping"));
    end
end

-- OnCreatePlayer adds callback for player OnCreatePlayerData event.
local function OnCreatePlayer(id)
    if not SandboxVars.ServerTweaker.SaveAdminPower then
        return
    end

    local ticker = {}

    ticker.OnTick = function()
        local character = getPlayer();

        if character then
            Events.OnTick.Remove(ticker.OnTick);
            SetAdminPower();
        end
    end

    Events.OnTick.Add(ticker.OnTick);
end

TweakFirearmsSoundRadius()

Events.OnGameStart.Add(OnGameStart);
Events.OnCreatePlayer.Add(OnCreatePlayer);
Events.OnGameBoot.Add(ClientTweaker.Items.Apply());
