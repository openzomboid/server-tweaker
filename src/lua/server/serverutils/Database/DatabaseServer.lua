--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

if isClient() then return end

local logger = ConsoleLogger.new()

local Bucket = {
    commands = {
        ["put"] = true, -- Inserts or replaces all data to new set.
        ["get"] = true, -- Returns all records.
        ["batch"] = true, -- Inserts or replaces array of records by keys.
        ["save"] = true, -- Inserts or replaces one record by key.
        ["view"] = true, -- Returns one record by key.
        ["delete"] = true -- Deletes one record by key.
    }
}

-- new creates instance of DatabaseServer and defines their methods.
function Bucket.new(name)
    name = name or "open-storage"

    local b = {
        data = {},
        name = name,
        filename = "opendb/" .. name .. ".json"
    }

    -- Put saves data to bucket. It replaces all data in the bucket.
    -- data must be a table.
    function b.Put(data)
        if data == nil or type(data) ~= "table" then
            return false
        end

        b.data = data

        return Bucket.writeFile(b)
    end

    -- Get return all the data from storage.
    function b.Get()
        return b.data
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

        return Bucket.writeFile(b)
    end

    -- Save saves value to storage by key name.
    function b.Save(key, value)
        if not key or type(key) ~= "string" or key == "" then
            return false
        end

        b.data[key] = value

        return Bucket.writeFile(b)
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
            return false
        end

        b.data[key] = nil

        return Bucket.writeFile(b)
    end

    -- Flush Saves data to file.
    function b.Flush()
        Bucket.writeFile(b)
    end

    Bucket.readFile(b)
    --Bucket.writeFile(b)

    return b
end

-- writeFile saves values to file in Zomboid/Lua directory.
function Bucket.writeFile(b)
    local writer = getFileWriter(b.filename, false, false)
    if not writer then
        return false
    end

    if b.data ~= nil and openutils.ObjectLen(b.data) > 0 then
        local encodeddata = openutils.json:encode(b.data)
        if encodeddata ~= nil then
            writer:write(encodeddata)
        end
    end

    writer:close()

    return true
end

-- readFile reads instance values from file in Zomboid/Lua directory.
function Bucket.readFile(b)
    local reader = getFileReader(b.filename, false)
    if not reader then
        return false
    end

    local rawdata = ""

    while true do
        local line = reader:readLine()
        if not line then
            reader:close()
            break
        end

        rawdata = rawdata .. line
    end

    if rawdata ~= "" then
        b.data = openutils.json:decode(rawdata)
    end

    return true
end

-- OnClientCommand handles client commands.
function Bucket.OnClientCommand(module, command, character, args)
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

    if not DatabaseServer.buckets[args.dbname] then
        return
    end

    local responseID = openutils.NewUUID()

    logger.Debug("OpenStorage: OnClientCommand validated", {request_id = args.request_id, dbname = args.dbname, command = command, response_id = responseID})

    local db = DatabaseServer.buckets[args.dbname]
    if not db then
        logger.Error("OpenStorage: db is not open or not exist", {request_id = args.request_id, dbname = args.dbname, command = command, response_id = responseID})
        return
    end

    if command == "put" then
        local ok = db.Put(args.data)
        if not ok then
            logger.Error("OpenStorage: failed put to db", {request_id = args.request_id, dbname = args.dbname, command = command, response_id = responseID})
            return
        end

        Bucket.SendToAllPlayers(character, {
            dbname = args.dbname,
            command = command,
            request_id = args.request_id,
            response_id = responseID,
            data = args.data
        })
    elseif command == "get" then
        if args.place then
            sendServerCommand(character, "ServerTweaker", args.place, {
                dbname = args.dbname,
                command = command,
                request_id = args.request_id,
                response_id = responseID,
                data = db.Get()
            })
        else
            Bucket.SendToAllPlayers(character, {
                dbname = args.dbname,
                command = command,
                request_id = args.request_id,
                response_id = responseID,
                data = db.Get()
            })
        end
    elseif command == "batch" then
        local ok = db.Batch(args.key_name, args.objects)
        if not ok then
            logger.Error("OpenStorage: failed batch save to db", {request_id = args.request_id, dbname = args.dbname, command = command, response_id = responseID})
            return
        end

        Bucket.SendToAllPlayers(character, {
            dbname = args.dbname,
            command = command,
            request_id = args.request_id,
            response_id = responseID,
            key_name = args.key_name,
            objects = args.objects
        })
    elseif command == "save" then
        local ok = db.Save(args.key, args.value)
        if not ok then
            logger.Error("OpenStorage: failed save to db", {request_id = args.request_id, dbname = args.dbname, command = command, response_id = responseID})
            return
        end

        Bucket.SendToAllPlayers(character, {
            dbname = args.dbname,
            command = command,
            request_id = args.request_id,
            response_id = responseID,
            key = args.key,
            value = args.value
        })
    elseif command == "view" then
        local data = db.View(args.key)
        if not data then
            logger.Error("OpenStorage: key \"" .. args.key .. "\" not found", {request_id = args.request_id, dbname = args.dbname, command = command, response_id = responseID})
            return
        end

        Bucket.SendToAllPlayers(character, {
            dbname = args.dbname,
            command = command,
            requestID = args.requestID,
            response_id = responseID,
            key = args.key,
            data = data
        })
    elseif command == "delete" then
        local ok = db.Delete(args.key)
        if not ok then
            logger.Error("OpenStorage: key \"" .. args.key .. "\" not found", {request_id = args.request_id, dbname = args.dbname, command = command, response_id = responseID})
            return
        end

        Bucket.SendToAllPlayers(character, {
            dbname = args.dbname,
            command = command,
            requestID = args.requestID,
            response_id = responseID,
            key = args.key
        })
    end
end

function Bucket.SendToAllPlayers(owner, args)
    -- Sync request owner first.
    sendServerCommand(owner, "ServerTweaker", "response", args)

    local onlineCharacters = getOnlinePlayers()

    for i=0, onlineCharacters:size()-1 do
        local character = onlineCharacters:get(i)

        if character and not character:isDead() then
            logger.Debug("OpenStorage: SendToAllPlayers", {request_id = args.request_id, dbname = args.dbname, username = character:getUsername()})

            if character:getUsername() ~= owner:getUsername() then
                sendServerCommand(character, "ServerTweaker", "response", args)
            end
        end
    end
end

Events.OnClientCommand.Add(Bucket.OnClientCommand)

DatabaseServer = {
    buckets = {}
}

function DatabaseServer.Open(name)
    if not name or type(name) ~= "string" or name == "" then
        return nil
    end

    logger.Debug("OpenStorage: open storage \"" .. name .. "\"")

    DatabaseServer.buckets[name] = Bucket.new(name)

    return DatabaseServer.buckets[name]
end
