--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

if isServer() then return end

-- openutils adds client defines to openutils.
openutils = openutils or {}

-- GetOnlineCharacterFromUsername finds player in online players list and returns character object.
function openutils.GetOnlineCharacterFromUsername(username)
    for i=1, getNumActivePlayers() do
        local character = getSpecificPlayer(i-1)

        if character and character:getUsername() == username then
            return character
        end
    end

    return nil
end
