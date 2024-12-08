--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

if isClient() then return end

-- openutils adds server defines to openutils.
openutils = openutils or {}

-- GetCharacterFromUsername finds player in online players list and returns character object.
function openutils.GetCharacterFromUsername(username)
    local onlineCharacters = getOnlinePlayers()

    for i=0, onlineCharacters:size()-1 do
        local character = onlineCharacters:get(i)

        if character:getUsername() == username then
            return character
        end
    end

    return nil
end
