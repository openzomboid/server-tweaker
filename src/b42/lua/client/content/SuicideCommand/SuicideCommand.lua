--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

-- SuicideCommand is a container table for the client-side suicide command
-- logic and store a reference to the original chat hook.
local SuicideCommand = {
    OriginalFunctions = {
        ISChat_onCommandEntered = ISChat.onCommandEntered
    }
}

-- onCommandEntered intercepts user input when they press Enter in the chat box.
-- Initializes and displays the confirmation modal window to prevent accidental deaths.
function SuicideCommand.onCommandEntered(self)
    local command = ISChat.instance.textEntry:getText();

    if command and command ~= "" then
        if SandboxVars.ServerTweaker.EnableSuicideCommand and command == "/suicide" then
            local modal = ISModalDialog:new(0, 0, 350, 150, getText("UI_SuicideConfirm"), true, nil, SuicideCommand.SuicideConfirmation)
            modal:initialise()
            modal:addToUIManager()

            ISChat.instance.textEntry:setText("")
        end
    end

    SuicideCommand.OriginalFunctions.ISChat_onCommandEntered(self)
end

-- SuicideConfirmation processes the player's choice inside the confirmation dialog.
-- Sends a command to the server to cause the player to die.
function SuicideCommand.SuicideConfirmation(dummy, button)
    if button.internal == "NO" then return end

    local character = getSpecificPlayer(0)
    if character then
        logger.Debug("SuicideCommand: Received suicide command confirmation")

        sendClientCommand(character, 'player', 'suicide', {})
    end
end

ISChat.onCommandEntered = SuicideCommand.onCommandEntered
