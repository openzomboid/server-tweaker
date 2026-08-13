--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

function Test_openutils_HasPermission()
    local passed = true

    local function do_test(testCase, characterRole, needleRole, expected)
        local character = {}
        character.getAccessLevel = function()
            return characterRole
        end

        local actual = openutils.HasPermission(character, needleRole)

        if actual == expected then
            print("[ .... ] " .. testCase .. " ... " .. testutils.green("passed"))
            return true
        else
            passed = false
            print("[ .... ] " .. testCase .. " ... " .. testutils.red("failed") ..  ": expected: " .. tostring(expected) .. ", actual: " .. tostring(actual))
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

    return passed
end