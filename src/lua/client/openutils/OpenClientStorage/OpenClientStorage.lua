--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local Bucket = {
    commands = {
        ["response"] = true,
    }
}

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

        print("OpenStorage: put to Bucket " .. b.name)

        b.data = data

        sendClientCommand(b.character, "ServerTweaker", "put", { dbname = b.name, request_id = openutils.NewUUID(), data = data })

        return true
    end

    -- Get return all the data from storage.
    function b.Get()
        print("OpenStorage: get from Bucket " .. b.name)

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

        print("OpenStorage: batch to Bucket " .. b.name)

        return true
    end

    -- Save saves value to storage by key name.
    function b.Save(key, value)
        if not key or type(key) ~= "string" or key == "" then
            return false
        end

        b.data[key] = value

        sendClientCommand(b.character, "ServerTweaker", "save", { dbname = b.name, request_id = openutils.NewUUID(), key = key, value = value })

        print("OpenStorage: save to Bucket " .. b.name)

        return true
    end

    -- View returns one value from storage by key.
    function b.View(key)
        if not key or type(key) ~= "string" or key == "" then
            return nil
        end

        print("OpenStorage: view from Bucket " .. b.name)

        return b.data[key]
    end

    sendClientCommand(b.character, "ServerTweaker", "get", { dbname = b.name, request_id = openutils.NewUUID() })

    return b
end

function Bucket.OnServerCommand(module, command, args)
    if not isClient() then return end

    if module ~= "ServerTweaker" then
        return
    end

    if not Bucket.commands[command] then
        return
    end

    if not args or type(args) ~= "table" then
        return
    end

    if not args.dbname or type(args.dbname) ~= "string" or args.dbname == "" then
        return
    end

    if not OpenClientStorage.buckets[args.dbname] then
        return
    end

    print("OpenStorage: OnClientCommand validated")

    if command == "response" then
        print("OpenStorage: receive response from db " .. args.dbname)

        if args.command == "get" then
            OpenClientStorage.buckets[args.dbname].data = args.data
        end
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

    print("OpenStorage: open storage \"" .. name .. "\"")

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

        local data = OpenClientStorage.services.View("Dead Harpy")
        if not data then
            return
        end

        character:Say(data.name)
    end
end

-- OnCreatePlayer adds callback for player OnCreatePlayerData event.
function TestRun.OnCreatePlayer(id)
    local ticker = {}

    ticker.OnTick = function()
        local character = getPlayer();

        if character then
            Events.OnTick.Remove(ticker.OnTick);
            OpenClientStorage.services = OpenClientStorage.Open("services")
        end
    end

    Events.OnTick.Add(ticker.OnTick);
end

Events.OnCreatePlayer.Add(TestRun.OnCreatePlayer);
TestRun.Test();
