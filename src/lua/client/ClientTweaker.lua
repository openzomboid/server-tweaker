--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

ClientTweaker = {
    Version = openutils.Version,
    -- Client options. Can be changed by every user.
    Options = OpenOptions:new("open-options", {
        -- Default values for options.
        ["highlight_safehouse"] = {type = "bool", value = "false"},
        ["show_ping"] = {type = "bool", value = "true"},
    }),
}

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
