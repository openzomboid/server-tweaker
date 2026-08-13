--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

function Test_OpenOptions_New()
    local passed = true

    local function do_test(testCase, key, value, expected)
        local options = OpenOptions:new("client-options-test", {
            [key] =  {type = "bool", value = value},
        });

        local actual = options.GetBool(key)

        if actual == expected then
            print("[ .... ] " .. testCase .. " ... " .. testutils.green("passed"))
            return true
        else
            passed = false
            print("[ .... ] " .. testCase .. " ... " .. testutils.red("failed") ..  ": expected: " .. tostring(expected) .. ", actual: " .. tostring(actual))
            return false
        end
    end

    os.remove(os.getenv("TESTDATA_PATH") .. "/" .. "client-options-test.ini")

    do_test("first", "highlight_safehouse", "true", true);
    do_test("exists", "highlight_safehouse", "false", true);

    os.remove(os.getenv("TESTDATA_PATH") .. "/" .. "client-options-test.ini")

    return passed
end

function Test_OpenOptions_Set()
    local passed = true

    local function do_test(testCase, key, defaultValue, setValue, expected)
        os.remove("lastday-test.ini")

        local options = OpenOptions:new("client-options-test", {
            [key] =  {type = "bool", value = defaultValue},
        });

        options.Set(key, {type = "bool", value = setValue})
        --options.SetBool(key, setValue)

        local actual = options.GetBool(key)

        os.remove(os.getenv("TESTDATA_PATH") .. "/" .. "client-options-test.ini")

        if actual == expected then
            print("[ .... ] " .. testCase .. " ... " .. testutils.green("passed"))
            return true
        else
            passed = false
            print("[ .... ] " .. testCase .. " ... " .. testutils.red("failed") ..  ": expected: " .. tostring(expected) .. ", actual: " .. tostring(actual))
            return false
        end
    end

    os.remove(os.getenv("TESTDATA_PATH") .. "/" .. "client-options-test.ini")

    do_test("first", "highlight_safehouse", false, true, true);
    do_test("exists", "highlight_safehouse", true, false, false);

    os.remove(os.getenv("TESTDATA_PATH") .. "/" .. "client-options-test.ini")

    return passed
end
