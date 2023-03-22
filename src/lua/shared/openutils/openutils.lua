--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

-- openutils contains shared defines.
openutils = {
    Version = "0.1.0", -- in semantic versioning (http://semver.org/)
    Color = {
        White = "<RGB:1,1,1>",
        Red = "<RGB:1,0,0>"
    },
    Role = {
        ["admin"] = 4, ["moderator"] = 3, ["gm"] = 2, ["observer"] = 1, ["none"] = 0,
    },
}

function openutils.HasPermission(character, needle)
    if character == nil then
        return false
    end

    local roleLevel = openutils.Role[string.lower(character:getAccessLevel())];
    if roleLevel == nil then roleLevel = 0 end

    local needleLevel = openutils.Role[string.lower(needle)]
    if needleLevel == nil then needleLevel = 99 end

    if roleLevel < needleLevel then
        -- Level is lower than needle level.
        return false
    end

    return true;
end

-- IsPointInRectangle returns true if XY point is inside the rectangle.
function openutils.IsPointInRectangle(x, y, x_top, y_top, x_bottom, y_bottom)
    return (x >= x_top and x <= x_bottom and y >= y_top and y <= y_bottom) or false;
end

-- GetSafehouseByXY returns safehouse by XY point.
function openutils.GetSafehouseByXY(x, y)
    local safehouses = SafeHouse.getSafehouseList();

    for i = 0, safehouses:size() - 1 do
        local safehouse = safehouses:get(i);

        if openutils.IsPointInRectangle(x, y, safehouse:getX(), safehouse:getY(), safehouse:getX2(), safehouse:getY2()) then
            return safehouse;
        end
    end

    return nil
end

function openutils.IsPlayerMemmberOfSafehouse(character, safehouse)
    local username = character:getUsername();

    if safehouse and username then
        if safehouse:playerAllowed(character) then return true; end;
        if safehouse:getOwner() == username then return true; end;

        local members = safehouse:getPlayers();

        if members then
            for i = 0, members:size() - 1 do
                if members:get(i) == username then
                    return true
                end
            end
        end
    end

    return false;
end

function openutils.SetSafehouseData(_title, _owner, _members, _x, _y, _w, _h)
    local playerObj = getSpecificPlayer(0);
    local safeObj = SafeHouse.addSafeHouse(_x, _y, _w, _h, _owner, false);
    safeObj:setTitle(_title);
    safeObj:setOwner(_owner);

    local members = luautils.split(_members, ",")

    if #members > 0 then
        for i = 1, #members do
            safeObj:addPlayer(members[i]);
        end
    end

    safeObj:updateSafehouse(playerObj);
    safeObj:syncSafehouse();
end

function openutils.RemoveDuplicates(list)
    local result, seen = {}, {}

    for _, item in ipairs(list) do
        if not seen[item] then
            seen[item] = true
            table.insert(result, item)
        end
    end

    return result
end
