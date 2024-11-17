--
-- Copyright (c) 2021 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local pzPath = os.getenv("PZ_PATH")

-- Import Tests utils.
dofile "testutils/testutils.lua"

-- Import Java zombie mock classes.
testutils.dotdir('mock/java')

-- Import Lua mock scripts.
testutils.dotdir('mock/lua/mods')

-- Import Lua shared Project Zomboid original scripts.
dofile(pzPath.."/media/lua/shared/luautils.lua")
dofile(pzPath.."/media/lua/shared/defines.lua")
--testutils.dotdir(pzPath.."/media/lua/shared") -- TODO: Add all java lasses mock first.
package.path = pzPath.."/media/lua/shared/" .. "?.lua;" .. package.path

function InitTest()
    -- TODO: Move SandboxVars to tests.
    SandboxVars.ServerTweaker = {}

    -- Import mod scripts.
    package.path = "../src/lua/shared/vendor/json.lua;" .. package.path
    testutils.dotdir('../src/lua/shared')

    -- Import mod tests.
    testutils.dotdirtests('../src/lua/shared')
end

function ClearTest()

end

InitTest()

--testutils.printTestFiles('../src/lua/shared')
testutils.runtests()

ClearTest()
