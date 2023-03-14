--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

if isClient() then return end

local OpenVehicleCommands = {}

OpenVehicleCommands.Disassemble = function(module, command, player, args)
    if module == 'vehicle' and command == "disassemble" then
        triggerEvent("OnClientCommand", module, "remove", player, args)
    end
end

Events.OnClientCommand.Add(OpenVehicleCommands.Disassemble)
