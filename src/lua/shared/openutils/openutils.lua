--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

-- openutils contains shared defines.
openutils = {
    Version = "0.3.2", -- in semantic versioning (http://semver.org/)
    Color = {
        White = "<RGB:1,1,1>",
        Red = "<RGB:1,0,0>"
    },
    Role = {
        ["admin"] = 5, ["moderator"] = 4, ["overseer"]= 3, ["gm"] = 2, ["observer"] = 1, ["none"] = 0,
    },
}

-- PrintObject prints object to console.
function openutils.PrintObject(o)
    if type(o) == 'table' then
        local str = '{\n';
        for k, v in pairs(o) do
            str = str .. k .. "\n";
        end

        return str .. '}\n'
    end

    if type(o) == "string" then
        return '"' .. tostring(o) .. '"'
    end

    return tostring(o)
end

-- PrintTableRecursive prints whole table to console.
function openutils.PrintTableRecursive(tbl, indent, depth)
    if not indent then indent = 0 end

    if depth ~= 0 and indent >= depth then
        return
    end

    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            openutils.PrintTableIndent(v, indent+1, depth)
        else
            print(formatting .. tostring(v))
        end
    end
end

-- PrintEvents prints loaded events to console.
function openutils.PrintEvents()
    print (openutils.PrintObject(Events));
end

-- RemoveDuplicates removes duplicates from list.
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

-- IsPointInRectangle returns true if XY point is inside the rectangle.
function openutils.IsPointInRectangle(x, y, x_top, y_top, x_bottom, y_bottom)
    return (x >= x_top and x <= x_bottom and y >= y_top and y <= y_bottom) or false;
end

-- HasPermission returns true if character's access level equal or greater
-- then needle. Otherwise returns false.
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

-- SetSafehouseData creates new SafeHouse.
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

-- IsIntersectingAnotherSafehouse returns true if coordinates belongs to another Safehouse.
function openutils.IsIntersectingAnotherSafehouse(X1, Y1, X2, Y2)
    for xVal = X1, X2-1 do
        for yVal = Y1, Y2-1 do
            local sqObj = getCell():getOrCreateGridSquare(xVal, yVal, 0);
            if sqObj then
                if SafeHouse.getSafeHouse(sqObj) then
                    return true;
                end
            end
        end
    end

    return false;
end

-- CanBeSafehouse checks a building in square to see if it can be a Safehouse.
function openutils.CanBeSafehouse(square, character, options)
    options = options or {
        SafehouseAreaLimit = 0,
        CheckSafehouseIntersections = false,
        SafehouseDeadZone = 0,
    }

    local building = square:getBuilding()
    if not building then
        return getText("ContextMenu_NotBuilding")
    end

    local def = building:getDef()
    if not def then
        return getText("ContextMenu_NotBuilding")
    end

    if options.SafehouseAreaLimit > 0 then
        local areaSize = def:getW() * def:getH()
        if areaSize > options.SafehouseAreaLimit then
            return getText("ContextMenu_BuildingIsTooBig")
        end
    end

    if options.CheckSafehouseIntersections then
        local x1 = def:getX()-2-options.SafehouseDeadZone;
        local y1 = def:getY()-2-options.SafehouseDeadZone;
        local x2 = def:getX2()+2+options.SafehouseDeadZone;
        local y2 = def:getY2()+2+options.SafehouseDeadZone;

        if openutils.IsIntersectingAnotherSafehouse(x1, y1, x2, y2) then
            return getText("ContextMenu_IntersectsWithAnotherSafehouse")
        end
    end

    return ""
end

-- IsPlayerMemmberOfSafehouse returns true if character is a member of safehouse.
-- There is an unexpected behavior that admins and other privileged users equated
-- to members.
-- TODO: Research this behavior. Maybe it will be better to split admins from players.
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

-- Suicide kills player who called this function.
function openutils.Suicide()
    local character = getPlayer()

    if character then
        character:setHealth(0);
    end
end
