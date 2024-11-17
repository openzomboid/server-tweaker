--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

function Test_ConsoleLogger_Customize()
    local passed = true

    local function do_test(testCase, level, expected)
        local logger = ConsoleLogger.new()

        local err = logger.Customize({Level = level, Prefix = ""})
        if err ~= expected then
            passed = false
            print("[ .... ] " .. testCase .. " ... " .. testutils.red("failed") .. ": expected err \"" .. tostring(expected) .. "\", got err \"" .. tostring(err) .. "\"")
            return false
        end

        print("[ .... ] " .. testCase .. " ... " .. testutils.green("passed"))

        return true
    end

    do_test("Correct Level", "trace", nil);
    do_test("Incorrect Level", "unknown", "receive incorrect Level");

    return passed
end

function Test_ConsoleLogger_log()
    local passed = true

    local function do_test(testCase, msg, data, expected)
        local out = {}

        local logger = ConsoleLogger.new()
        logger.SetOutput(out)

        logger.Debug(msg, data)

        local actual = out[1]

        if actual ~= expected then
            passed = false
            print("[ .... ] " .. testCase .. " ... " .. testutils.red("failed") .. ": expected \"" .. tostring(expected) .. "\", actual \"" .. tostring(actual) .. "\"")
            return false
        end

        print("[ .... ] " .. testCase .. " ... " .. testutils.green("passed"))

        return true
    end

    do_test("Skip data1", "Test me in 1", "dsf", "ST DEBUG: Test me in 1");
    do_test("Skip data2", "Test me in 2", {[1] = 3}, "ST DEBUG: Test me in 2 {}");
    do_test("Add data", "Test me in 3", {data = "test", moredata = {ddata = "dadataaa"}}, 'ST DEBUG: Test me in 3 {"data": "test", "moredata": {"ddata": "dadataaa"}}');
    do_test("No data", "Test me in 4", nil, "ST DEBUG: Test me in 4");

    return passed
end
