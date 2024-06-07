--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

if isClient() then return end

require "OpenServerStorage/OpenServerStorage"

local OpenServerStorageCommands = {
    commands = {
        ["put"] = true,
        ["get"] = true,
        ["batch"] = true,
        ["save"] = true,
        ["view"] = true,
    }
}

OpenServerStorageCommands.OnClientCommand = function(module, command, character, args)
    if module ~= "ServerTweaker" then
        return
    end

    if not OpenServerStorageCommands.commands[command] then
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
        return
    elseif command == "get" then
        print("OpenStorage: get from db " .. args.dbname .. " not implemented")
        return
    elseif command == "batch" then
        print("OpenStorage: batch save to db " .. args.dbname .. " not implemented")
        return
    elseif command == "save" then
        print("OpenStorage: save to db " .. args.dbname .. " not implemented")
        return
    elseif command == "view" then
        print("OpenStorage: view from db " .. args.dbname)

        local data = db.View("Dead Harpy")
        if data.name then
            print("OpenStorage: got value " .. data.name)
        else
            print("OpenStorage: value not found")
        end

        local response = {
            dbname = args.dbname,
            command = command,
            requestID = args.requestID,
            data = data
        }
        sendServerCommand(character, "ServerTweaker", "response", response)

        return
    end
end

Events.OnClientCommand.Add(OpenServerStorageCommands.OnClientCommand)
