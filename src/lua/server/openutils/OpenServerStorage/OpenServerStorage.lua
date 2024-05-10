--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local json = require "vendor/json"

OpenServerStorage = {}

-- new creates instance of OpenServerStorage and defines their methods.
function OpenServerStorage:new(name)
    if name == nil then name = "open-storage" end

    local instance = {
        data = {},
        filename = "opendb/" .. name .. ".json"
    }

    -- Write saves values to file in Zomboid/Lua directory.
    function instance.Write()
        local writer = getFileWriter(instance.filename, false, false)
        if not writer then return end

        if instance.data ~= nil and openutils.ObjectLen(instance.data) > 0 then
            local encodeddata = json:encode(instance.data)
            if encodeddata ~= nil then
                writer:write(encodeddata)
            end
        end

        writer:close()
    end

    -- Read reads instance values from file in Zomboid/Lua directory.
    function instance.Read()
        local reader = getFileReader(instance.filename, false)
        if not reader then return end

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
            instance.data = json:decode(rawdata)
        end
    end

    function instance.BatchSave(object)
        if object == nil or type(object) ~= "table" then
            return false
        end

        instance.data = object
        instance.Write()

        return true
    end

    function instance.GetPage()
        return instance.data
    end

    instance.Read()
    instance.Write()

    return instance
end
