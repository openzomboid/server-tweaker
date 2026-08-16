--
-- Copyright (c) 2026 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

-- SuicideCommandServer is a container table for the server-side suicide command logic.
local SuicideCommandServer = {}

-- KillPlayer handles the forced execution of character death on the server side.
function SuicideCommandServer.KillPlayer(character)
    if not character then return end

    local bodyDamage = character:getBodyDamage()
    if bodyDamage then
        bodyDamage:ReduceGeneralHealth(100.0)
        character:setHealth(0.0)

        bodyDamage:Update()
        character:update()
    end
end

-- onClientCommand intercepts commands sent from client-side instances.
function SuicideCommandServer.onClientCommand(module, command, character, args)
    if not character then return end

    if module == 'player' and command == "suicide" then
        logger.Debug("SuicideCommandServer: Receive valid player suicide command for " .. character:getUsername())

        SuicideCommandServer.KillPlayer(character)
    end
end

Events.OnClientCommand.Add(SuicideCommandServer.onClientCommand)
