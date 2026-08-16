--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

--- =========================================================================================================
--- PUBLIC MODULE: OptionsStorage
--- =========================================================================================================

--- OptionsStorage wraps Project Zomboid's native Java File I/O Streams to create an isolated,
--- lightweight key-value configuration reader and writer. It parses and formats raw plain-text .ini
--- data documents saved directly into the 'C:\Users\Username\Zomboid\Lua\' system user directories.
OptionsStorage = OptionsStorage or {}

--- OptionsStorage:new instantiates an independent configuration storage runtime lane and auto-executes startup disk
--- processing sweeps.
---
--- @param name string|nil The custom configuration file name layout (omitting extensions; defaults to "open-options")
--- @param options table|nil Optional default blueprint dictionary profile tree containing pre-defined typed structures
--- @return table Returns an activated local instance object containing specialized accessor methods
---
--- @example Instantiation pattern via a Public API framework module (e.g., ClientOptions.AddOption):
---     if ClientOptions.Storage == nil then
---         -- Allocates an isolated file context targeting "Zomboid/Lua/client-options.ini"
---         ClientOptions.Storage = OptionsStorage:new("client-options", {})
---     end
function OptionsStorage:new(name, options)
    if options == nil then options = {} end
    if name == nil then name = "open-options" end

    -- instance is the underlying private data dictionary mapping models
    local instance = {
        options = options,
        filename = name .. ".ini"
    }

    --- Write flushes current in-memory configurations out to the local system file system track.
    --- Implements a complete rewrite loop using a raw text line buffer block structure.
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

    --- Read streams text fields out of the local disk storage file path and builds data cache trees.
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

                -- Dynamic Schema Blueprint Assignment Pass:
                if instance.options[key] == nil then
                    -- If a setting node doesn't exist in cache, guess type schemas implicitly and assign values
                    instance.options[key] = {type = typeof(value), value = value}
                elseif instance.options[key] ~= nil and instance.options[key].type ~= "" then
                    -- If an option template already exists, preserve its defined data type layout while updating the value field
                    instance.options[key].value = value
                end
            end
        end

        logger.Debug("OptionsStorage: Finished read file " .. instance.filename, instance.options)
    end

    --- Set validates object formats, pushes items to memory mapping trees, and fires file flushes.
    --- @param key string Configuration key identifier node track
    --- @param option table Schema dictionary payload containing typing definitions and value nodes
    --- @return boolean Returns true if writing processes were successful, false if errors are encountered
    function instance.Set(key, option)
        if key == nil or type(key) ~= "string" or option == nil or option.type == nil or option.value == nil then
            return false
        end

        instance.options[key] = option
        instance.Write()

        return true
    end

    --- SetString commits values explicitly designated with raw String signatures.
    --- @example ClientOptions.SetString("server_ip", "127.0.0.1")
    function instance.SetString(key, value)
        return instance.Set(key, {type = "string", value = value})
    end

    --- SetBool commits values explicitly designated with Boolean signatures.
    --- @example ClientOptions.SetBool("highlight_safehouse", true)
    function instance.SetBool(key, value)
        return instance.Set(key, {type = "bool", value = value})
    end

    --- SetInt commits values explicitly designated with Integer signatures.
    --- @example ClientOptions.SetInt("max_render_distance", 30)
    function instance.SetInt(key, value)
        return instance.Set(key, {type = "int", value = value})
    end

    --- Get returns the target data record map container block directly.
    --- @return table|nil Configuration properties table element or nil if key entry remains unmatched
    function instance.Get(key)
        return instance.options[key]
    end

    --- GetString extracts configurations and safely enforces type normalization back to safe String tracks.
    --- @return string The configuration text property or empty string as fallback tracking
    function instance.GetString(key)
        local option = instance.options[key] or {}
        local value = option.value or "";
        if value == nil then
            value = ""
        end

        return tostring(value)
    end

    --- GetBool extracts stored plain-text strings and returns authentic operational Boolean variables.
    --- @return boolean Resolves string data signatures like "true" back to literal system boolean flags
    ---
    --- @example Invoking boolean recovery from an external option API framework layer:
    ---     option.selected = ClientOptions.Storage.GetBool("highlight_safehouse")
    function instance.GetBool(key)
        local option = instance.options[key] or {}
        local value = option.value or false;
        if value == "true" or value == true then
            return true
        end

        return false
    end

    --- GetInt extracts values and wraps conversions to safe numeric integer layers.
    --- @return number Evaluates parameters back into functional integers or handles fallback returns to 0
    function instance.GetInt(key)
        local option = instance.options[key] or {}
        local value = option.value or 0;
        return tonumber(value) or 0
    end

    --- Start coordinates execution flows when storage handlers initialize.
    function instance.Start()
        instance.Read()
        instance.Write()
    end

    instance.Start()

    return instance
end
