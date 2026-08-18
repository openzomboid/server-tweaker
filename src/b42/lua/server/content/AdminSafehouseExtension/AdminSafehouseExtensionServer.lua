--
-- Copyright (c) 2026 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

local AdminSafehouseExtensionServer = {}

-- AdminSafehouseExtensionServer.onClientCommand processes incoming network packets transmitted
-- from a client to the server.
-- Upon intercepting the "ISAddSafeZoneUI_create" event, it sanitizes the payload, applies the safehouse
-- configurations to the database via local utilities, and broadcasts a confirmation response back to the player.
function AdminSafehouseExtensionServer.onClientCommand(module, command, character, args)
    if not character then return end

    if module == "ServerTweaker" and command == "ISAddSafeZoneUI_create" then
        logger.Debug("AdminSafehouseExtensionServer: Receive safehouse creation event from " .. character:getUsername(), args)

        if not args or type(args) ~= "table" then
            return
        end

        openutils.SetSafehouseData(args.title, args.owner, args.members, args.x, args.y, args.w, args.h)

        sendServerCommand(character, "ServerTweaker", "ISAddSafeZoneUI_create", args)
    end
end

Events.OnClientCommand.Add(AdminSafehouseExtensionServer.onClientCommand)
