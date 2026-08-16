--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

--- =========================================================================================================
--- PUBLIC CLASS / MODULE: ConsoleLogger
--- =========================================================================================================

--- ConsoleLogger implements an isolated, configurable application logger that routes system traces,
--- warnings, and structured object states directly into Project Zomboid's central 'server-console.txt' file.
ConsoleLogger = ConsoleLogger or {}

--- GetDefaultConfig returns the base global fallback configurations map used when instantiating raw loggers.
--- @return table Dictionary defining default output severity constraints and identifying console labels.
function ConsoleLogger.GetDefaultConfig()
    return {
        Level = "debug",
        Prefix = "ConsoleLogger",
    }
end

--- ConsoleLogger.new generates a distinct logging instance containing granular diagnostic level methods.
--- @return table Returns an activated logger object equipped with context isolation interfaces.
---
--- @example Standard structural call initialization across your mod framework:
---     local logger = ConsoleLogger.new()
---     logger.Debug("Hello from the mod pipeline!")
---
--- @example Logging text alongside complex structured Lua data tables:
---     local sessionData = { username = "testuser", safehouses = 3 }
---     logger.Info("Synchronizing safehouses database", sessionData)
function ConsoleLogger.new()
    -- Initialize the primary local instance dictionary payload to expose public interfaces
    local logger = {}

    -- Severity Level Map: Establishes a mathematical hierarchical value loop to handle conditional log filtering
    local levels = {["disabled"] = 0, ["trace"] = 1, ["debug"] = 2, ["info"] = 3, ["warning"] = 4, ["error"] = 5}
    local config = ConsoleLogger.GetDefaultConfig() -- Load clone copy of fallback blueprint metrics
    local output = nil -- Reference hook used to intercept prints and redirect logs into memory arrays

    -- Local memory pool tracking unique message strings to suppress duplicate print calls
    local printedMessages = {}

    --- addFields converts an unmapped Lua table layout structure into a formatted JSON-like string.
    --- Enforces rigid alphabetical ordering on table keys to guarantee clean, deterministic console debugging reads.
    --- @param value any Can accept tables, nested objects, strings, numbers, or boolean parameters
    --- @return string Formatted string serialization of the provided value data node
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

    --- log filters messages against severity constraints and outputs formatted text.
    --- @param level number The numerical priority rank value representing the message severity status
    --- @param msg string The informational message string to print out to console fields
    --- @param ... any Optional secondary table parameters intended for structured serialization processing passes
    local function log(level, msg, ...)
        local args = {...}
        local fields = args[1]

        -- Block and silence prints if message rank falls beneath user minimum thresholds
        local minLevel = levels[config.Level]
        if not minLevel or level < minLevel then
            return nil -- Level is lower than min level
        end

        -- Construct log string layouts beginning with custom branding prefixes
        local prefix = config.Prefix
        if prefix ~= "" then
            prefix = prefix .. " "
        end

        -- Map numeric priority indicators safely back to standardized text channel identifiers
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
            prefix = prefix .. "ERROR: "
        end

        -- Parse secondary data attachments if available and concatenate strings cleanly
        if fields and type(fields) == "table" then
            msg = msg .. " " .. addFields(fields)
        end

        if output ~= nil and type(output) == "table" then
            -- Inject compiled string logs straight into memory tables for unit testing procedures
            table.insert(output, prefix..msg)
        else
            -- Flush structured text string straight into game console streams via print()
            print(prefix..msg)
        end
    end

    -- Public API Channel Mappings: Route distinct methods cleanly down inside targeted severity filters
    function logger.Trace(msg, ...) log(1, msg, ...) end
    function logger.Debug(msg, ...) log(2, msg, ...) end
    function logger.Info(msg, ...) log(3, msg, ...) end
    function logger.Warning(msg, ...) log(4, msg, ...) end
    function logger.Error(msg, ...) log(5, msg, ...) end

    --- PrintOnce prints a log message exactly once per session.
    --- Subsequent identical calls will be completely suppressed to prevent console flooding.
    --- @param severity string The target level threshold for this log (e.g., "info", "debug")
    --- @param msg string The clear informational message string to print out to console fields
    --- @param ... any Optional secondary table parameters intended for structured serialization processing passes
    ---
    --- @example Suppressing continuous noise from on-tick updates or rendering passes:
    ---     function HighlightSafehouse.OnRenderTick(ticks)
    ---         if not safehouses then
    ---             -- This error would normalmente flood the log 60 times per second.
    ---             -- Using PrintOnce prints it exactly one time, then falls completely silent.
    ---             logger.PrintOnce("warning", "Safehouses database is empty or not loaded yet")
    ---             return
    ---         end
    ---     end
    function logger.PrintOnce(severity, msg, ...)
        -- Fallback to info severity tracking if string is wrong
        local numericLevel = levels[severity] or 3

        -- Check if this specific exact text string already exists inside the duplicate prevention directory pool
        if printedMessages[msg] then
            return
        end

        -- Pass the operational parameters directly down inside standard logging filters
        log(numericLevel, msg, ...)

        -- Register the message text as a static hash key to trap duplicates later
        printedMessages[msg] = true
    end

    --- ResetOncePool clears the internal history cache of unique printed messages.
    --- Allowing previously suppressed logs to be printed one more time if called again.
    ---
    --- @example Resetting log constraints when a player switches maps or triggers a reload:
    ---     function MyModUI.onReset()
    ---         -- Purges the printedMessages pool memory footprint
    ---         logger.ResetOncePool()
    ---         logger.PrintOnce("info", "System context re-initialized") -- This will print again!
    ---     end
    function logger.ResetOncePool()
        printedMessages = {}
    end

    --- Customize modifies the active instance's operational properties at runtime.
    --- @param cfg table Configuration dictionary defining fresh Level and Prefix values
    --- @return string|nil Returns a validation error string, or nil if customization processes complete successfully
    ---
    --- @example Customizing a logger for your ClientOptions public API:
    ---     local apiLogger = ConsoleLogger.new()
    ---     apiLogger.Customize({ Level = "info", Prefix = "[OptionsAPI]" })
    ---     apiLogger.Info("API Layer Initialized") -- Outputs: "[OptionsAPI] INFO: API Layer Initialized"
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

    --- SetLevel explicitly adjusts the active severity logging threshold level.
    --- Provides a dedicated single-purpose modifier function for managing logging visibility filters at runtime.
    --- @param severity string The new minimum log level severity threshold string (e.g., "info", "warning", "disabled")
    --- @return string|nil Returns a validation error message string if the layout signature is incorrect, or nil if validation passes
    ---
    --- @example Dynamically muting trace and debug noise outside of test environments:
    ---     local logger = ConsoleLogger.new()
    ---     logger.SetLevel("info")
    ---     logger.Debug("This will NOT be printed")
    ---     logger.Info("This WILL be printed")
    function logger.SetLevel(severity)
        -- Fallback guard: Validate if the requested level value key matches an established registry index map slot
        if not severity or not levels[severity] then
            return "receive incorrect level"
        end

        config.Level = severity
        return nil
    end

    --- SetOutput dynamic pointer rerouting used to swap standard console prints with table injection blocks.
    --- @param out table|nil A target table container arrays node where text entries should be redirected, or nil to reset
    function logger.SetOutput(out)
        if out ~= nil and type(out) == "table" then
            output = out
        end
    end

    return logger
end
