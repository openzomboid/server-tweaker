--
-- Copyright (c) 2022 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakChat = {
    Original = {
        onToggleChatBox = ISChat.onToggleChatBox
    }
}

-- onToggleChatBox overrides the original ISChat.onToggleChatBox function.
-- Changes default chat steam to /all instead /say.
TweakChat.onToggleChatBox = function(key)
    if ISChat.instance == nil then return; end

    if SandboxVars.ServerTweaker.SetGeneralChatStreamAsDefault then
        if key == getCore():getKey("Toggle chat") or key == getCore():getKey("Alt toggle chat") then
            if ISChat.fairLastChatCommand == nil then
                ISChat.fairLastChatCommand = false

                ISChat.instance.chatText.streamID = 6;
                ISChat.instance.chatText.lastChatCommand = ISChat.allChatStreams[6].command;
            end
        end
    end

    TweakChat.Original.onToggleChatBox(key)
end

ISChat.onToggleChatBox = TweakChat.onToggleChatBox;
