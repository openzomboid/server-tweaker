--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

ClientTweaker = {
    Version = openutils.Version,
    -- Client options. Can be changed by every user.
    Options = OpenOptions:new("client-options", {
        -- Default values for options.
        ["highlight_safehouse"] = {type = "bool", value = "false"},
        ["show_ping"] = {type = "bool", value = "true"},
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

-- OnGameStart adds callback for OnGameStart global event.
local function OnGameStart()
    if SandboxVars.ServerTweaker.DisableAimOutline then
        getCore():setOptionAimOutline(1);
    end

    local player = getPlayer();
    if player then
        ClientTweaker.Storage = OpenUserStorage:new(player:getUsername())
    end

    setShowConnectionInfo(true);
    setShowServerInfo(false);
    setShowPingInfo(ClientTweaker.Options.GetBool("show_ping"));
end

TweakFirearmsSoundRadius()

Events.OnGameStart.Add(OnGameStart);
Events.OnGameBoot.Add(ClientTweaker.Items.Apply());
