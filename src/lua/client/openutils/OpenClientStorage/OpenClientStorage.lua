--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local Response = {}

local Bucket = {}

function Bucket.new(name)
    name = name or "open-storage"

    local b = {
        data = {},
        name = name,
        character = getPlayer()
    }

    -- Put saves data to bucket. It replaces all data in the bucket.
    -- data must be a table.
    function b.Put(data)
        if data == nil or type(data) ~= "table" then
            return false
        end

        b.data = data

        sendClientCommand(b.character, "ServerTweaker", "put", { dbname = b.name, request_id = openutils.NewUUID(), data = data })

        return true
    end

    -- Get return all the data from storage.
    function b.Get()
        return b.data
    end

    -- Batch writes table data to storage by key name.
    function b.Batch(key, objects)
        if not key or type(key) ~= "string" or key == "" then
            return false
        end

        if objects == nil or type(objects) ~= "table" then
            return false
        end

        for _, line in pairs(objects) do
            if line[key] then
                b.data[key] = line[key]
            end
        end

        sendClientCommand(b.character, "ServerTweaker", "batch", { dbname = b.name, request_id = openutils.NewUUID(), key = key, objects = objects })

        return true
    end

    -- Save saves value to storage by key name.
    function b.Save(key, value)
        if not key or type(key) ~= "string" or key == "" then
            return false
        end

        b.data[key] = value

        sendClientCommand(b.character, "ServerTweaker", "save", { dbname = b.name, request_id = openutils.NewUUID(), key = key, value = value })

        return true
    end

    -- View returns one value from storage by key.
    function b.View(key)
        if not key or type(key) ~= "string" or key == "" then
            return nil
        end

        return b.data[key]
    end

    return b
end

function Bucket.OnServerCommand(module, command, args)
    if not isClient() then return end

    if module == "ServerTweaker" and command == "response" then
        local character = getPlayer()

        --character:Say(args.data.name)

        Response[args.request_id] = args
    end
end

Events.OnServerCommand.Add(Bucket.OnServerCommand);

OpenClientStorage = {
    buckets = {}
}

function OpenClientStorage.Open(name)
    if not name or type(name) ~= "string" or name == "" then
        return nil
    end

    OpenClientStorage.buckets[name] = Bucket.new(name)

    return OpenClientStorage.buckets[name]
end

--
-- Test
--

local TestRun = {}

function TestRun.Test()
    local originalTransferItem = ISInventoryTransferAction.transferItem

    ISInventoryTransferAction.transferItem = function(self, item)
        originalTransferItem(self, item)

        local character = getPlayer()

        sendClientCommand(character, "ServerTweaker", "view", { dbname = "services" })
    end
end

function TestRun.OnGameStart()
    OpenClientStorage.services = OpenClientStorage.Open("services")
end

--Events.OnGameStart.Add(TestRun.OnGameStart);
--TestRun.Test();