--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

-- OptionsStorage implements mod configuration reader and writer.
OptionsStorage = OptionsStorage or {}

-- new creates instance of OptionsStorage and defines their methods.
function OptionsStorage:new(name, options)
    if options == nil then options = {} end
    if name == nil then name = "open-options" end

    -- instance is main instance of OptionsStorage class.
    local instance = {
        options = options,
        filename = name .. ".ini"
    }

    -- Write saves config values to file in Zomboid/Lua directory.
    function instance.Write()
        logger.Debug("OptionsStorage: Started write to file " .. instance.filename, instance.options)

        if openutils and openutils.ObjectLen(instance.options) <= 0 then
            logger.Debug("OptionsStorage: Nothing write to file " .. instance.filename)

            return
        end

        local writer = getFileWriter(instance.filename, true, false)

        for key, option in pairs(instance.options) do
            writer:write(key .. "=" .. tostring(option.value) .. "\r\n")
        end

        writer:close()

        logger.Debug("OptionsStorage: Finished write to file " .. instance.filename)
    end

    -- Read reads instance values from file in Zomboid/Lua directory.
    function instance.Read()
        logger.Debug("OptionsStorage: Started read file " .. instance.filename)

        local reader = getFileReader(instance.filename, false)
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

                if instance.options[key] == nil then
                    instance.options[key] = {type = typeof(value), value = value}
                elseif instance.options[key] ~= nil and instance.options[key].type ~= "" then
                    instance.options[key].value = value
                end
            end
        end

        logger.Debug("OptionsStorage: Finished read file " .. instance.filename, instance.options)
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

    function instance.Start()
        instance.Read()
        instance.Write()
    end

    instance.Start()

    return instance
end
