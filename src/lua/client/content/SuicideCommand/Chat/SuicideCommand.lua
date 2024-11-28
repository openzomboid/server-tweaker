--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local SuicideCommand = {
    ISChat = {
        onCommandEntered = ISChat.onCommandEntered
    }
}

-- onCommandEntered overrides the original ISChat.onCommandEntered function.
-- Adds suicide command to chat.
function SuicideCommand.onCommandEntered(self)
    local command = ISChat.instance.textEntry:getText();

    if command and command ~= "" then
        if SandboxVars.SerwerTweaker.EnableSuicideCommand and command == "/suicide" then
            SuicideCommand.OnSuicideCommand()
            ISChat.instance.textEntry:setText("");
        end
    end

    SuicideCommand.ISChat.onCommandEntered(self)
end

-- OnSuicideCommand kills current player.
function SuicideCommand.OnSuicideCommand()
    local modal = ISModalDialog:new(0, 0, 350, 150, getText("UI_SuicideConfirm"), true, nil, SuicideCommand.SuicideConfirmation)
    modal:initialise()
    modal:addToUIManager()
end

function SuicideCommand.SuicideConfirmation(dummy, button)
    if button.internal == "NO" then return end

    local character = getSpecificPlayer(0)
    if character then
        character:setHealth(0);
    end
end

ISChat.onCommandEntered = SuicideCommand.onCommandEntered;
