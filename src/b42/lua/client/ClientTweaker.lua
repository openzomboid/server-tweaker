--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

ClientTweaker = {
    Version = openutils.Version,
    Cache = nil,
}

-- OnGameStart adds callback for OnGameStart global event.
function ClientTweaker.OnGameStart()
    if SandboxVars.ServerTweaker.AddClientCache then
        local player = getPlayer()
        if player then
            ClientTweaker.Cache = OpenCache:new(player:getUsername())
        end
    end
end

Events.OnGameStart.Add(ClientTweaker.OnGameStart)
