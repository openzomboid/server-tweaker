--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

-- ConsoleLogger implements simple logger to server-console.txt file.
ConsoleLogger = ConsoleLogger or {}

-- GetConfig returns config values for ConsoleLogger configuration.
function ConsoleLogger.GetConfig()
    return {
        Level = "debug",
        Prefix = "ConsoleLogger",
    }
end

-- new creates instance of ConsoleLogger and defines their methods.
-- Usage:
-- logger.Debug("Test me in 1")
-- logger.Debug("Test me in 2", {data = "test", moredata = {ddata = "dadataaa"})
function ConsoleLogger.new()
    -- logger is main instance of ConsoleLogger class.
    local logger = {}

    local levels = {["disabled"] = 0, ["trace"] = 1, ["debug"] = 2, ["info"] = 3, ["warning"] = 4, ["error"] = 5}
    local config = ConsoleLogger.GetConfig()
    local output = nil

    -- addFields converts a Lua value to a json-like string. Converts Table fields in alphabetical order.
    local function addFields(value)
        local str = ''

        if (type(value) ~= 'table') then
            if (type(value) == 'string') then
                str = string.format("%q", value)
            else
                str = tostring(value)
            end
        else
            local auxTable = {}
            for key in pairs(value) do
                if (tonumber(key) ~= key) then
                    table.insert(auxTable, key)
                else
                    --table.insert(auxTable, addFields(key))
                end
            end
            table.sort(auxTable)

            str = str..'{'
            local separator = ""
            local entry = ""
            for _, fieldName in ipairs(auxTable) do
                if ((tonumber(fieldName)) and (tonumber(fieldName) > 0)) then
                    entry = addFields(value[tonumber(fieldName)])
                else
                    entry = '"' .. fieldName .. '": ' .. addFields(value[fieldName])
                end
                str = str..separator..entry
                separator = ", "
            end
            str = str..'}'
        end

        return str
    end

    -- log prints log line.
    local function log(level, msg, ...)
        local args = {...}
        local fields = args[1]

        local minLevel = levels[config.Level]
        if not minLevel or level < minLevel then
            -- Level is lower than min level.
            return nil
        end

        local prefix = config.Prefix
        if prefix ~= "" then
            prefix = prefix .. " "
        end

        if level == 0 then
            return nil
        elseif level == 1 then
            prefix = prefix .. "TRACE: "
        elseif level == 2 then
            prefix = prefix .. "DEBUG: "
        elseif level == 3 then
            prefix = prefix .. "INFO: "
        elseif level == 4 then
            prefix = prefix .. "WARNING: "
        elseif level == 5 then
            prefix = prefixx .. "ERROR: "
        end

        if fields and type(fields) == "table" then
            msg = msg .. " " .. addFields(fields)
        end

        if output ~= nil and type(output) == "table" then
            table.insert(output, prefix..msg)
        else
            print(prefix..msg)
        end
    end

    function logger.Trace(msg, ...) log(1, msg, ...) end
    function logger.Debug(msg, ...) log(2, msg, ...) end
    function logger.Info(msg, ...) log(3, msg, ...) end
    function logger.Warning(msg, ...) log(4, msg, ...) end
    function logger.Error(msg, ...) log(5, msg, ...) end

    -- Customize imports config.
    function logger.Customize(cfg)
        if not cfg then
            return "receive empty config"
        end

        if levels[cfg.Level] then
            config.Level = cfg.Level
        else
            return "receive incorrect Level"
        end

        if cfg.Prefix ~= nil then
            config.Prefix = cfg.Prefix
        end

        return nil
    end

    -- SetOutput changes stream to print log lines.
    function logger.SetOutput(out)
        if out ~= nil and type(out) == "table" then
            output = out
        end
    end

    return logger
end
