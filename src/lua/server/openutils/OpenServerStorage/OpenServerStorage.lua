--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

if isClient() then return end

local json = require "vendor/json"

local Bucket = {
    commands = {
        ["put"] = true,
        ["get"] = true,
        ["batch"] = true,
        ["save"] = true,
        ["view"] = true,
    }
}

-- new creates instance of OpenServerStorage and defines their methods.
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

        print("OpenStorage: put to Bucket " .. b.name)

        b.data = data

        return Bucket.writeFile(b)
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

        print("OpenStorage: batch to Bucket " .. b.name)

        return Bucket.writeFile(b)
    end

    -- Save saves value to storage by key name.
    function b.Save(key, value)
        if not key or type(key) ~= "string" or key == "" then
            return false
        end

        b.data[key] = value

        print("OpenStorage: save to Bucket " .. b.name)

        return Bucket.writeFile(b)
    end

    -- View returns one value from storage by key.
    function b.View(key)
        if not key or type(key) ~= "string" or key == "" then
            return nil
        end

        print("OpenStorage: view from Bucket " .. b.name)

        return b.data[key]
    end

    Bucket.readFile(b)
    Bucket.writeFile(b)

    return b
end

-- Flush saves values to file in Zomboid/Lua directory.
function Bucket.writeFile(b)
    local writer = getFileWriter(b.filename, false, false)
    if not writer then
        return false
    end

    if b.data ~= nil and openutils.ObjectLen(b.data) > 0 then
        local encodeddata = json:encode(b.data)
        if encodeddata ~= nil then
            writer:write(encodeddata)
        end
    end

    writer:close()

    return true
end

-- Read reads instance values from file in Zomboid/Lua directory.
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
        b.data = json:decode(rawdata)
    end

    return true
end

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

    if not OpenServerStorage.buckets[args.dbname] then
        return
    end

    print("OpenStorage: OnClientCommand validated")

    local db = OpenServerStorage.buckets[args.dbname]

    if command == "put" then
        print("OpenStorage: put to db " .. args.dbname .. " not implemented")
    elseif command == "get" then
        print("OpenStorage: get from db " .. args.dbname)

        sendServerCommand(character, "ServerTweaker", "response", {
            dbname = args.dbname,
            command = command,
            requestID = args.requestID,
            data = db.Get()
        })
    elseif command == "batch" then
        print("OpenStorage: batch save to db " .. args.dbname .. " not implemented")
    elseif command == "save" then
        print("OpenStorage: save to db " .. args.dbname .. " not implemented")
    elseif command == "view" then
        print("OpenStorage: view from db " .. args.dbname)

        local data = db.View(args.key)
        if not data then
            print("OpenStorage: key \"" .. args.key .. "\" not found")
        else
            print("OpenStorage: got value by key \"" .. data.name .. "\"")
        end

        sendServerCommand(character, "ServerTweaker", "response", {
            dbname = args.dbname,
            command = command,
            requestID = args.requestID,
            data = data
        })
    end
end

Events.OnClientCommand.Add(Bucket.OnClientCommand)

OpenServerStorage = {
    buckets = {}
}

function OpenServerStorage.Open(name)
    if not name or type(name) ~= "string" or name == "" then
        return nil
    end

    print("OpenStorage: open storage \"" .. name .. "\"")

    OpenServerStorage.buckets[name] = Bucket.new(name)

    return OpenServerStorage.buckets[name]
end

--
-- Test
--

local TestRun = {}

function TestRun.OnServerStarted()
    OpenServerStorage.Open("services")
end

Events.OnServerStarted.Add(TestRun.OnServerStarted);
