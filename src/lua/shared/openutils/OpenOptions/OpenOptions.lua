--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

-- OpenOptions implements mod configuration reader and writer.
OpenOptions = OpenOptions or {}

-- new creates instance of OpenOptions and defines their methods.
function OpenOptions:new(name, options)
    if options == nil then options = {} end
    if name == nil then name = "open-options" end

    local filename = name .. ".ini"

    -- instance is main instance of OpenOptions class.
    local instance = {
        options = options,
        filename = name .. ".ini"
    }

    -- Write saves config values to file in Zomboid/Lua directory.
    function instance.Write()
        local writer = getFileWriter(instance.filename, true, false)

        for key, option in pairs(instance.options) do
            writer:write(key .. "=" .. tostring(option.value) .. "\r\n")
        end

        writer:close()
    end

    -- Read reads instance values from file in {{GameCache}}/Lua directory.
    function instance.Read()
        local reader = getFileReader(filename, false)
        if not reader then return end

        while true do
            local line = reader:readLine()
            if not line then
                reader:close()
                break
            end

            if line:find("=") then
                local arr = luautils.split(line, "=")
                local key = arr[1]
                local value = arr[2]

                if value == nil then
                    value = ""
                end

                if instance.options ~= nil and instance.options[key] ~= nil and instance.options[key].type ~= "" then
                    instance.options[key].value = value
                end
            end
        end
    end

    function instance.Set(key, option)
        if key == nil or type(key) ~= "string" or option == nil or option.type == nil or option.value == nil then
            return false
        end

        instance.options[key] = option
        instance.Write()

        return true
    end

    function instance.SetString(key, value)
        return instance.Set(key, {type = "string", value = value})
    end

    function instance.SetBool(key, value)
        return instance.Set(key, {type = "bool", value = value})
    end

    function instance.SetInt(key, value)
        return instance.Set(key, {type = "int", value = value})
    end

    function instance.Get(key)
        return instance.options[key]
    end

    function instance.GetString(key)
        local option = instance.options[key] or {}
        local value = option.value or "";
        if value == nil then
            value = ""
        end

        return tostring(value)
    end

    function instance.GetBool(key)
        local option = instance.options[key] or {}
        local value = option.value or false;
        if value == "true" or value == true then
            return true
        end

        return false
    end

    function instance.GetInt(key)
        local option = instance.options[key] or {}
        local value = option.value or 0;
        return tonumber(value) or 0
    end

    instance.Read()
    instance.Write()

    return instance
end
