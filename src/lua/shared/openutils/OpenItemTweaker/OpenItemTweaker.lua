--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

OpenItemTweaker = OpenItemTweaker or {}

function OpenItemTweaker:new()
    local tweaker = {
        items = {}
    }

    -- Apply changes properties for items in list.
    function tweaker.Apply()
        local item;

        for k,v in pairs(tweaker.items) do
            for t,y in pairs(v) do
                item = ScriptManager.instance:getItem(k);
                if item ~= nil then
                    item:DoParam(t.." = "..y);
                end
            end
        end
    end

    -- Add adds item to tweak list.
    function tweaker.Add(name, key, value)
        if not tweaker.items[name] then
            tweaker.items[name] = {};
        end

        tweaker.items[name][key] = value;
    end

    return tweaker
end
