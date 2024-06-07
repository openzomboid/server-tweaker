--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local OpenClientStorageCommands = {}

OpenClientStorageCommands.OnServerCommand = function(module, command, args)
    if not isClient() then return end

    if module == "ServerTweaker" and command == "response" then
        local character = getPlayer()

        character:Say(args.data.name)
    end
end

--Events.OnServerCommand.Add(OpenClientStorageCommands.OnServerCommand)
