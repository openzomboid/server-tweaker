--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

OpenCache = {}

function OpenCache:new(username)
    local logger = ConsoleLogger.new()

    local startTimeMs = nil
    local WAIT_DURATION_MS = 3000 -- 3 seconds
    local tickCounter = 0

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

        storage.safehouses[key] = safehouse
    end

    -- DelSafehouse deletes safehouse from list.
    function storage.DelSafehouse(safehouse)
        if not instanceof(safehouse, 'SafeHouse') then
            return
        end

        local key = tostring(safehouse:getX()) .. "," .. tostring(safehouse:getY()) .. "," .. tostring(safehouse:getW()) .. "," .. tostring(safehouse:getH())

        storage.safehouses[key] = nil
    end

    -- FillSafehouses adds all safehouses to list by username.
    function storage.FillSafehouses()
        storage.safehouses = {}

        local safehouseList = SafeHouse.getSafehouseList()
        for i = 1, safehouseList:size() do
            local safehouse = safehouseList:get(i - 1)

            if safehouse then
                if openutils.IsUsernameMemberOfSafehouse(storage.username, safehouse) then
                    storage.AddSafehouse(safehouse)
                end
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

    -- doInitialLoadTick monitors network load and waits for safehouses to be received from the server.
    local function doInitialLoadTick()
        local calendar = Calendar.getInstance()
        local currentTimeMs = calendar:getTimeInMillis()

        if not startTimeMs then
            startTimeMs = currentTimeMs
        end

        local safehouseList = SafeHouse.getSafehouseList()
        local hasData = safehouseList and safehouseList:size() > 0
        local isTimeout = (currentTimeMs - startTimeMs) >= WAIT_DURATION_MS

        tickCounter = tickCounter +1

        -- If the data has appeared or the waiting time has expired
        if hasData or isTimeout then
            Events.OnTick.Remove(doInitialLoadTick)

            storage.FillSafehouses()
            storage.StartSync()

            logger.Debug("OpenCache: initial sync completed on " .. tostring(calendar:getTimeInMillis() - startTimeMs) .. " ms with " .. tostring(tickCounter) .. " ticks")

            startTimeMs = nil
            tickCounter = 0
        end
    end

    function storage.init()
        startTimeMs = nil
        tickCounter = 0

        -- Запускаем отложенную проверку вместо мгновенного вызова FillSafehouses
        Events.OnTick.Add(doInitialLoadTick)
    end

    storage.init()

    return storage
end
