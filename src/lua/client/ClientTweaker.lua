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
    Items = {},
}

-- ApplyTweakItems changes properties for items in list.
ClientTweaker.ApplyTweakItems = function()
    local item;

    for k,v in pairs(ClientTweaker.Items) do
        for t,y in pairs(v) do
            item = ScriptManager.instance:getItem(k);
            if item ~= nil then
                item:DoParam(t.." = "..y);
            end
        end
    end
end

-- TweakFirearmsSoundRadius returns SoundRadius to 41.56 values for firearms
-- if enabled.
ClientTweaker.TweakFirearmsSoundRadius = function(name, key, value)
    if SandboxVars.ServerTweaker.TweakFirearmsSoundRadius then
        ClientTweaker.TweakItem("Base.Pistol3", "SoundRadius", "100");
        ClientTweaker.TweakItem("Base.Pistol2", "SoundRadius", "70");
        ClientTweaker.TweakItem("Base.Revolver_Short", "SoundRadius", "30");
        ClientTweaker.TweakItem("Base.Revolver", "SoundRadius", "70");
        ClientTweaker.TweakItem("Base.Pistol", "SoundRadius", "50");
        ClientTweaker.TweakItem("Base.Revolver_Long", "SoundRadius", "120");

        ClientTweaker.TweakItem("Base.DoubleBarrelShotgun", "SoundRadius", "200");
        ClientTweaker.TweakItem("Base.DoubleBarrelShotgunSawnoff", "SoundRadius", "250");
        ClientTweaker.TweakItem("Base.Shotgun", "SoundRadius", "200");
        ClientTweaker.TweakItem("Base.ShotgunSawnoff", "SoundRadius", "250");

        ClientTweaker.TweakItem("Base.AssaultRifle2", "SoundRadius", "90");
        ClientTweaker.TweakItem("Base.AssaultRifle", "SoundRadius", "100");
        ClientTweaker.TweakItem("Base.VarmintRifle", "SoundRadius", "150");
        ClientTweaker.TweakItem("Base.HuntingRifle", "SoundRadius", "150");
    end
end

-- TweakItem adds item to tweak list.
ClientTweaker.TweakItem = function(name, key, value)
    if not ClientTweaker.Items[name] then
        ClientTweaker.Items[name] = {};
    end

    ClientTweaker.Items[name][key] = value;
end

-- OnGameStart adds callback for OnGameStart global event.
ClientTweaker.OnGameStart = function()
    if SandboxVars.ServerTweaker.DisableAimOutline then
        getCore():setOptionAimOutline(1);
    end

    setShowConnectionInfo(true);
    setShowServerInfo(false);
    setShowPingInfo(ClientTweaker.Options.GetBool("show_ping"));
end

Events.OnGameStart.Add(ClientTweaker.OnGameStart);
Events.OnGameBoot.Add(ClientTweaker.ApplyTweakItems);
