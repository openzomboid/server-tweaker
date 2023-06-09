--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local pzPath = os.getenv("PZ_PATH")

-- Import Java zombie mock classes.

-- Import Lua mock scripts.

-- Import Lua Project Zomboid original scripts.
dofile(pzPath.."/media/lua/shared/luautils.lua")

package.path = pzPath.."/media/lua/shared/" .. "?.lua;" .. package.path
package.path = pzPath.."/media/lua/client/" .. "?.lua;" .. package.path

-- Import indirect Lua Project Zomboid original scripts.

-- Import Server Tweaker mod scripts.

-- This test is test nothing yet.
print("> " .. "No tests available")

os.remove("client-options-test.ini");
