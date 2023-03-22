--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local function isPlayerMemberOfSafehouse(username, safehouse)
    if not instanceof(safehouse, 'SafeHouse') then
        return false
    end

    if safehouse:getOwner() == username then
        return true;
    end;

    local members = safehouse:getPlayers();

    if members then
        for j = 0, members:size() - 1 do
            if members:get(j) == username then
                return true
            end
        end
    end
end

OpenUserStorage = OpenUserStorage or {}

function OpenUserStorage:new(username)
    local storage = {
        username = username,
        safehouses = {},

        started = false,
    }

    -- GetSafehouses returns safehouses allowed to user.
    function storage.GetSafehouses()
        return storage.safehouses or {}
    end

    -- AddSafehouse adds safehouse to list.
    function storage.AddSafehouse(safehouse)
        if not instanceof(safehouse, 'SafeHouse') then
            return
        end
        
        local key = tostring(safehouse:getX()) .. "," .. tostring(safehouse:getY()) .. "," .. tostring(safehouse:getW()) .. "," .. tostring(safehouse:getH())

        storage.safehouses[key] = safehouse;
    end

    -- DelSafehouse deletes safehouse from list.
    function storage.DelSafehouse(safehouse)
        if not instanceof(safehouse, 'SafeHouse') then
            return
        end

        local key = tostring(safehouse:getX()) .. "," .. tostring(safehouse:getY()) .. "," .. tostring(safehouse:getW()) .. "," .. tostring(safehouse:getH())

        storage.safehouses[key] = nil;
    end

    -- FillSafehouses adds all safehouses to list by username.
    function storage.FillSafehouses()
        storage.safehouses = {}

        local safehouseList = SafeHouse.getSafehouseList();
        for i = 0, safehouseList:size() - 1 do
            local safehouse = safehouseList:get(i);

            if isPlayerMemberOfSafehouse(storage.username, safehouse) then
                storage.AddSafehouse(safehouse)
            end
        end
    end

    function storage.StartSync()
        if storage.started then
            return
        end

        storage.started = true
        Events.OnSafehousesChanged.Add(storage.FillSafehouses)
    end

    function storage.StopSync()
        if not storage.started then
            return
        end

        storage.started = false
        Events.OnSafehousesChanged.Remove(storage.FillSafehouses)
    end

    storage.FillSafehouses()
    storage.StartSync()

    return storage
end
