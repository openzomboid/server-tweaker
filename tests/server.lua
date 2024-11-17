--
-- Copyright (c) 2021 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--
-- LastDay mod is created for Last Day server.
--

function isClient()
    return false
end

function isServer()
    return true
end

local pzPath = os.getenv("PZ_PATH")
testdataPath = os.getenv("TESTDATA_PATH")

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
--testutils.dotdir(pzPath.."/media/lua/server") -- TODO: Add all java lasses mock first.
package.path = pzPath.."/media/lua/shared/" .. "?.lua;" .. package.path
package.path = pzPath.."/media/lua/server/" .. "?.lua;" .. package.path

dofile(pzPath.."/media/lua/server/Vehicles/Vehicles.lua") -- in server/tweaks/Vehicles/TweakVehicles.lua:10
dofile(pzPath.."/media/lua/server/BuildingObjects/ISDestroyCursor.lua") -- in ISDestroyCursor_FixDestroyCursorInSafehouse.lua:9

function InitTest()
    -- TODO: Move SandboxVars to tests.
    SandboxVars.LastDay = {}
    SandboxVars.LastDay.LoggerDisabled = false
    SandboxVars.LastDay.LoggerLevel = "debug"

    SandboxVars.Trader = {}
    SandboxVars.Trader.SellDivider = 7

    -- Import mod scripts.
    package.path = "../src/lua/shared/vendor/json.lua;" .. package.path
    testutils.dotdir('../src/lua/shared')
    testutils.dotdir('../src/lua/server')

    -- Import mod tests.
    testutils.dotdirtests('../src/lua/server')
end

function ClearTest()

end

InitTest()

--testutils.printTestFiles('../src/lua/server')
testutils.runtests()

ClearTest()
