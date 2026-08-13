--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

OpenItemTweaker = {
    tweaker = nil
}

function OpenItemTweaker:new()
    if OpenItemTweaker.tweaker then
        return OpenItemTweaker.tweaker
    end

    local tweaker = {
        items = {},
        started = false,
    }

    -- Apply changes properties for items in list.
    function tweaker.Apply()
        for k, v in pairs(tweaker.items) do
            for t, y in pairs(v) do
                local item = ScriptManager.instance:getItem(k);
                if item ~= nil then
                    item:DoParam(t.." = " .. y);
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

    function tweaker.StartTweaker()
        if tweaker.started then
            return
        end

        tweaker.started = true
        Events.OnGameBoot.Add(tweaker.Apply);
    end

    function tweaker.StopTweaker()
        if not tweaker.started then
            return
        end

        tweaker.started = false
        Events.OnGameBoot.Remove(tweaker.Apply)
    end

    tweaker.StartTweaker()

    OpenItemTweaker.tweaker = tweaker;

    return tweaker
end
