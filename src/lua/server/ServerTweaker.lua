--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

ServerTweaker = {
    Version = openutils.Version,
    Storage = nil,
}

function ServerTweaker.OnServerStarted() end

Events.OnServerStarted.Add(ServerTweaker.OnServerStarted);
