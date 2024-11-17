--
-- Copyright (c) 2021 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

function isClient()
    return true
end

function isServer()
    return false
end

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
--testutils.dotdir(pzPath.."/media/lua/shared") -- TODO: Add all java classes mock first.
--testutils.dotdir(pzPath.."/media/lua/client") -- TODO: Add all java classes mock first.
package.path = pzPath.."/media/lua/shared/" .. "?.lua;" .. package.path
package.path = pzPath.."/media/lua/client/" .. "?.lua;" .. package.path

dofile(pzPath.."/media/lua/client/Chat/ISChat.lua") -- in ChatCommands.lua:9
dofile(pzPath.."/media/lua/client/ISUI/AdminPanel/ISAdminPanelUI.lua") -- in tweaks/ISUI/AdminPanel/TweakAdminPanelUI.lua:9
dofile(pzPath.."/media/lua/client/Vehicles/ISUI/ISVehicleMenu.lua") -- tweaks/Vehicles/ISUI/TweakVehicleMenu.lua:19
dofile(pzPath.."/media/lua/client/OptionScreens/MainOptions.lua") -- tweaks/OptionScreens/TweakMainOptions.lua:9
dofile(pzPath.."/media/lua/client/TimedActions/ISDestroyStuffAction.lua") -- in ISDestroyStuffAction_ProtectSafehouseExtraLines.lua:9

dofile(pzPath.."/media/lua/client/ISUI/UserPanel/ISUserPanelUI.lua") -- in tweaks/ISUI/UserPanel/TweakUserPanelUI.lua:11
dofile(pzPath.."/media/lua/client/ISUI/AdminPanel/ISMiniScoreboardUI.lua") -- indirect in lua/client/ISUI/UserPanel/ISSafehouseAddPlayerUI.lua:200
dofile(pzPath.."/media/lua/client/ISUI/UserPanel/ISSafehouseAddPlayerUI.lua") -- in tweaks/ISUI/UserPanel/TweakISSafehouseAddPlayerUI.lua:9
dofile(pzPath.."/media/lua/client/ISUI/UserPanel/ISSafehouseUI.lua") -- in tweaks/ISUI/UserPanel/TweakSafehouseUI.lua:13
dofile(pzPath.."/media/lua/client/ISUI/PlayerStats/ISPlayerStatsUI.lua") -- in tweaks/ISUI/PlayerStats/TweakPlayerStatsUI.lua:9
dofile(pzPath.."/media/lua/client/ISUI/ISCollapsableWindowJoypad.lua") -- indirect in lua/client/ISUI/Maps/ISWorldMap.lua:15
dofile(pzPath.."/media/lua/client/ISUI/Maps/ISWorldMap.lua") -- in tweaks/ISUI/Maps/TweakWorldMap.lua:9
dofile(pzPath.."/media/lua/client/ISUI/ISEquippedItem.lua") -- in tweaks/ISUI/TweakEquippedItem.lua:11
dofile(pzPath.."/media/lua/client/ISUI/AdminPanel/ISAddSafeZoneUI.lua") -- in tweaks/ISUI/AdminPanel/TweakAddSafeZoneUI.lua:13
dofile(pzPath.."/media/lua/client/ISUI/AdminPanel/ISAdminPowerUI.lua") -- in tweaks/ISUI/AdminPanel/TweakISAdminPowerUI.lua:11
dofile(pzPath.."/media/lua/client/XpSystem/ISUI/ISCharacterScreen.lua") -- in tweaks/XpSystem/ISUI/TweakCharacterScreen.lua:9
dofile(pzPath.."/media/lua/client/DebugUIs/AdminContextMenu.lua") -- in client/tweaks/DebugUIs/TweakAdminContextMenu.lua:9
dofile(pzPath.."/media/lua/client/Vehicles/ISUI/ISVehicleMechanics.lua") -- in tweaks/Vehicles/ISUI/TweakVehicleMechanics.lua:10
dofile(pzPath.."/media/lua/client/OptionScreens/MapSpawnSelect.lua") -- in tweaks/OptionScreens/TweakMapSpawnSelect.lua:9

function InitTest()
    -- TODO: Move SandboxVars to tests.
    SandboxVars.ServerTweaker = {}

    -- Import mod scripts.
    package.path = "../src/lua/shared/vendor/json.lua;" .. package.path
    testutils.dotdir('../src/lua/shared')
    testutils.dotdir('../src/lua/client')

    -- Import mod tests.
    testutils.dotdirtests('../src/lua/client')
end

function ClearTest()

end

InitTest()

--testutils.printTestFiles('../src/lua/client')
testutils.runtests()

ClearTest()
