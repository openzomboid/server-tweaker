--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

local Bucket = {
    commands = {
        ["response"] = true,
    },
    response = {}
}

function Bucket.new(name)
    name = name or "open-storage"

    local b = {
        data = {},
        name = name
    }

    -- Put saves data to bucket. It replaces all data in the bucket.
    -- data must be a table.
    function b.Put(data)
        if data == nil or type(data) ~= "table" then
            return false
        end

        b.data = data

        Bucket.send(b, "put", { dbname = b.name, data = data })

        return true
    end

    -- Get return all the data from storage.
    function b.Get()
        return b.data
    end

    function b.GetFromServer(place)
        Bucket.send(b, "get", { dbname = b.name, place = place })
    end

    -- Batch writes table data to storage by key name.
    function b.Batch(keyName, objects)
        if not keyName or type(keyName) ~= "string" or keyName == "" then
            return false
        end

        if objects == nil or type(objects) ~= "table" then
            return false
        end

        for _, line in pairs(objects) do
            if line[keyName] then
                b.data[keyName] = line[keyName]
            end
        end

        Bucket.send(b, "batch", { dbname = b.name, key_name = keyName, objects = objects })

        return true
    end

    -- Save saves value to storage by key name.
    function b.Save(key, value)
        if not key or type(key) ~= "string" or key == "" then
            return false
        end

        b.data[key] = value

        Bucket.send(b, "save", { dbname = b.name, key = key, value = value })

        return true
    end

    -- View returns one value from storage by key.
    function b.View(key)
        if not key or type(key) ~= "string" or key == "" then
            return nil
        end

        return b.data[key]
    end

    -- Delete deletes one value from storage by key.
    function b.Delete(key)
        if not key or type(key) ~= "string" or key == "" then
            return nil
        end

        b.data[key] = nil

        Bucket.send(b, "delete", { dbname = b.name, key = key })

        return b.data[key]
    end

    Bucket.send(b, "get", { dbname = b.name })

    return b
end

function Bucket.send(b, command, args)
    local character = getPlayer()
    args.request_id = openutils.NewUUID()

    sendClientCommand(character, "LastDay", command, args)
end

-- OnServerCommand handles commands from server with db responses.
function Bucket.OnServerCommand(module, command, args)
    if not isClient() then return end

    if module ~= "LastDay" then
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

    if not DatabaseClient.buckets[args.dbname] then
        return
    end

    local character = getPlayer()

    logger.Debug("OpenStorage: OnServerCommand validated", {
        request_id = args.request_id,
        dbname = args.dbname,
        command = command,
        response_id = args.response_id,
        args_command = args.command,
        args_key = args.key,
        username = character:getUsername()
    })

    if command == "response" then
        if args.command == "put" then
            DatabaseClient.buckets[args.dbname].data = args.data
        elseif args.command == "get" then
            DatabaseClient.buckets[args.dbname].data = args.data
        elseif args.command == "batch" then
            for _, line in pairs(args.objects) do
                if line[args.key_name] then
                    DatabaseClient.buckets[args.dbname].data[args.key_name] = line[args.key_name]
                end
            end
        elseif args.command == "save" then
            DatabaseClient.buckets[args.dbname].data[args.key] = args.value
        elseif args.command == "view" then
            DatabaseClient.buckets[args.dbname].data[args.key] = args.value
        elseif args.command == "delete" then
            DatabaseClient.buckets[args.dbname].data[args.key] = nil
        end
    end
end

Events.OnServerCommand.Add(Bucket.OnServerCommand);

DatabaseClient = {
    buckets = {}
}

function DatabaseClient.Open(name)
    if not name or type(name) ~= "string" or name == "" then
        return nil
    end

    local ticker = {}

    ticker.OnTick = function()
        local character = getPlayer();

        if character then
            Events.OnTick.Remove(ticker.OnTick);

            DatabaseClient.buckets[name] = Bucket.new(name)

            logger.Debug("OpenStorage: complete open storage \"" .. name .. "\"")
        end
    end

    Events.OnTick.Add(ticker.OnTick);

    logger.Debug("OpenStorage: start open storage \"" .. name .. "\"")
end
