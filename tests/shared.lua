--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local pzPath = os.getenv("PZ_PATH")

-- Import Java zombie mock classes.
dofile "mock/java/GlobalObject.lua"
dofile "mock/java/SandboxVars.lua"

-- Import Lua mock scripts.

-- Import Lua Project Zomboid original scripts.
dofile(pzPath.."/media/lua/shared/luautils.lua")

package.path = pzPath.."/media/lua/shared/" .. "?.lua;" .. package.path

-- Import Server Tweaker mod scripts.
dofile "../src/lua/shared/openutils/OpenOptions/OpenOptions.lua"
dofile "../src/lua/shared/openutils/openutils.lua"

function Test_OpenOptions_New()
    local testName = "Test_OpenOptions_New"
    print("> " .. testName)

    local function do_test(testCase, key, value, expected)
        local options = OpenOptions:new("client-options-test", {
            [key] =  {type = "bool", value = value},
        });

        local actual = options.GetBool(key)

        if actual == expected then
            print(">> " .. testName .. "." .. testCase .. ": Passed")
            return true
        else
            print(">> " .. testName .. "." .. testCase .. ": expected: " .. tostring(expected) .. ", actual: " .. tostring(actual))
            return false
        end
    end

    os.remove("client-options-test.ini")

    do_test("first", "highlight_safehouse", "true", true);
    do_test("exists", "highlight_safehouse", "false", true);

    os.remove("client-options-test.ini")
end

function Test_OpenOptions_Set()
    local testName = "Test_OpenOptions_Set"
    print("> " .. testName)

    local function do_test(testCase, key, defaultValue, setValue, expected)
        os.remove("lastday-test.ini")

        local options = OpenOptions:new("client-options-test", {
            [key] =  {type = "bool", value = defaultValue},
        });

        options.Set(key, {type = "bool", value = setValue})
        --options.SetBool(key, setValue)

        local actual = options.GetBool(key)

        os.remove("client-options-test.ini")

        if actual == expected then
            print(">> " .. testName .. "." .. testCase .. ": Passed")
            return true
        else
            print(">> " .. testName .. "." .. testCase .. ": expected: " .. tostring(expected) .. ", actual: " .. tostring(actual))
            return false
        end
    end

    do_test("first", "highlight_safehouse", false, true, true);
    do_test("exists", "highlight_safehouse", true, false, false);
end

function Test_openutils_HasPermission()
    local testName = "Test_openutils_HasPermission"
    print("> " .. testName)

    local function do_test(testCase, characterRole, needleRole, expected)
        local character = {}
        character.getAccessLevel = function()
            return characterRole
        end

        local actual = openutils.HasPermission(character, needleRole)

        if actual == expected then
            print(">> " .. testName .. "." .. testCase .. ": Passed")
            return true
        else
            print(">> " .. testName .. "." .. testCase .. ": expected: " .. tostring(expected) .. ", actual: " .. tostring(actual))
            return false
        end
    end

    do_test("user_greater", "admin", "moderator", true);
    do_test("needle_greater", "moderator", "admin", false);
    do_test("equal", "moderator", "moderator", true);
    do_test("needle_greater2", "gm", "moderator", false);
    do_test("user_not_exist", "not_exist", "moderator", false);
    do_test("needle_not_exist", "moderator", "not_exist", false);
    do_test("both_not_exist", "not_exist", "not_exist", false);
end

Test_OpenOptions_New()
Test_OpenOptions_Set()
Test_openutils_HasPermission()
