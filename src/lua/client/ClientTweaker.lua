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
    Cache = nil,
}

-- OnGameStart adds callback for OnGameStart global event.
function ClientTweaker.OnGameStart()
    if SandboxVars.ServerTweaker.AddClientCache then
        local player = getPlayer();
        if player then
            ClientTweaker.Cache = OpenCache:new(player:getUsername())
        end
    end

    if SandboxVars.ServerTweaker.SaveClientOptions then
        setShowPingInfo(ClientTweaker.Options.GetBool("show_ping"));
    end
end

Events.OnGameStart.Add(ClientTweaker.OnGameStart);
