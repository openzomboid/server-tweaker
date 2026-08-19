--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

-- storage is a singleton reference holder.
-- Stores the active cache instance to prevent multiple allocations across scripts.
local storage = nil

--- =========================================================================================================
--- PUBLIC MODULE: SafehousesCache
--- =========================================================================================================

--- SafehousesCache implements an optimized local database cache for safehouses. Instead of calling expensive
--- Java queries (SafeHouse.getSafehouseList()) inside high-frequency frames like OnRenderTick, this module
--- tracks player safehouses in local memory and listens to server synchronization update hooks.
SafehousesCache = {}

--- SafehousesCache:new initializes a new cache manager or returns the existing singleton instance.
---
--- @return table|nil Returns the active cached storage object API interface, or nil if player is not fully loaded.
---
--- @example Instantiating the cache inside an external mod file (e.g., HighlightSafehouse.OnGameStart):
---     function HighlightSafehouse.OnGameStart()
---         if HighlightSafehouse.IsEnabledOnServer() then
---             -- Creates and starts automatic data synchronization for the local player's safehouses
---             HighlightSafehouse.SafehousesCache = SafehousesCache:new()
---         end
---     end
function SafehousesCache:new()
    -- Internal tracking references used exclusively by the asynchronous loading cycle
    local startTimeMs = nil
    local WAIT_DURATION_MS = 3000 -- Guard timeout threshold (3 seconds) to force load if server list data is delayed
    local tickCounter = 0

    -- If a functional cache already exists in memory, return it immediately
    -- to prevent redundant loop iterations and double event subscriptions.
    if storage then
        logger.Debug("SafehousesCache: Cache storage already created")

        return storage
    end

    local character = getPlayer()
    if not character then
        logger.Debug("SafehousesCache: Cache storage doesn't created")

        return nil
    end
    
    local username = character:getUsername()

    -- Instantiate the central storage object structure that will be exposed as the public API surface
    storage = {
        username = username,
        safehouses = {},

        started = false,
    }

    --- GetSafehouses safely returns the local dictionary map containing player safehouses.
    ---
    --- @return table Map structure where keys are coordinate strings and values are Java 'SafeHouse' objects.
    ---
    --- @example Consuming data inside a render tick (e.g., HighlightSafehouse.OnRenderTick):
    ---     local safehouses = HighlightSafehouse.SafehousesCache.GetSafehouses()
    ---     for _, safehouse in pairs(safehouses) do
    ---         local x = safehouse:getX()
    ---         -- process rendering calculations...
    ---     end
    function storage.GetSafehouses()
        return storage.safehouses or {}
    end

    --- AddSafehouse registers a valid safehouse entity into the local storage memory table.
    ---
    --- @param safehouse SafeHouse The native Java safehouse object instance to register.
    function storage.AddSafehouse(safehouse)
        if not instanceof(safehouse, 'SafeHouse') then
            return
        end

        local key = tostring(safehouse:getX()) .. "," .. tostring(safehouse:getY()) .. "," .. tostring(safehouse:getW()) .. "," .. tostring(safehouse:getH())

        storage.safehouses[key] = safehouse
    end

    --- DelSafehouse deregisters and removes a specific safehouse entry from the memory table.
    ---
    --- @param safehouse SafeHouse The native Java safehouse object instance to remove.
    function storage.DelSafehouse(safehouse)
        if not instanceof(safehouse, 'SafeHouse') then
            return
        end

        local key = tostring(safehouse:getX()) .. "," .. tostring(safehouse:getY()) .. "," .. tostring(safehouse:getW()) .. "," .. tostring(safehouse:getH())

        storage.safehouses[key] = nil
    end

    --- FillSafehouses queries the global game world engine database to find safehouses linked to the user.
    function storage.FillSafehouses()
        storage.safehouses = {}

        local safehouseList = SafeHouse.getSafehouseList()
        for i = 1, safehouseList:size() do
            local safehouse = safehouseList:get(i - 1)

            if safehouse and openutils.IsUsernameMemberOfSafehouse(storage.username, safehouse) then
                storage.AddSafehouse(safehouse)
            end
        end
    end

    --- StartSync subscribes to native global engine events to automatically update cache data when changes occur.
    function storage.StartSync()
        if storage.started then
            return
        end

        storage.started = true
        Events.OnSafehousesChanged.Add(storage.FillSafehouses)
    end

    --- StopSync unsubscribes from active game event handlers to pause live background data synchronization.
    function storage.StopSync()
        if not storage.started then
            return
        end

        storage.started = false
        Events.OnSafehousesChanged.Remove(storage.FillSafehouses)
    end

    --- Asynchronous frame routine that waits for server network synchronization packets
    --- to settle down completely before running the initial database extraction sweeps.
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

        if hasData or isTimeout then
            Events.OnTick.Remove(doInitialLoadTick)

            storage.FillSafehouses()
            storage.StartSync()

            logger.Debug("SafehousesCache: initial sync completed on " .. tostring(calendar:getTimeInMillis() - startTimeMs) .. " ms with " .. tostring(tickCounter) .. " ticks")

            startTimeMs = nil
            tickCounter = 0
        end
    end

    --- init sets up startup variables and hooks the temporary frame tick listener.
    function storage.init()
        startTimeMs = nil
        tickCounter = 0

        -- Run a delayed check hook instead of calling storage.FillSafehouses() immediately.
        -- When a world loads, SafeHouse.getSafehouseList() remains completely empty for a few frames while the server
        -- syncs database streams down to the client. Waiting prevents the cache from initializing completely blank.
        Events.OnTick.Add(doInitialLoadTick)
    end

    storage.init()

    logger.Debug("SafehousesCache: Created new cache storage")

    return storage
end
