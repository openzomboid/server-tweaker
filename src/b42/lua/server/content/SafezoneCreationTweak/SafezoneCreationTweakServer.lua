--
-- Copyright (c) 2026 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

local SafezoneCreationTweakServer = {}

function SafezoneCreationTweakServer.onClientCommand(module, command, character, args)
    if not character then return end

    if module == "ServerTweaker" and command == "ISAddSafeZoneUI_create" then
        logger.Debug("SafezoneCreationTweakServer: Receive safehouse creation event from " .. character:getUsername(), args)

        if not args or type(args) ~= "table" then
            return
        end

        openutils.SetSafehouseData(args.title, args.owner, args.members, args.x, args.y, args.w, args.h)

        sendServerCommand(character, "ServerTweaker", "ISAddSafeZoneUI_create", args)
    end
end

Events.OnClientCommand.Add(SafezoneCreationTweakServer.onClientCommand)
