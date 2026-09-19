--
-- Copyright (c) 2026 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

-- Global module table for managing satellite/terrain view injection into Build 42 world maps.
AddSatelliteViewToMap = {
    OriginalFunctions = {
        ISWorldMap_createChildren = ISWorldMap.createChildren,
        WorldMapOptions_getVisibleOptions = WorldMapOptions.getVisibleOptions,
        ISWorldMap_prerender = ISWorldMap.prerender,
        ISWorldMap_saveSettings = ISWorldMap.saveSettings,
        ISWorldMap_restoreSettings = ISWorldMap.restoreSettings,
    }
}

--- IsEnabledOnServer checks if the satellite map view tweak is enabled in sandbox settings
--- and debug mode is off.
--- @return boolean
function AddSatelliteViewToMap.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.AddSatelliteViewToMap and not getDebug()
end

--- checkTerrainImage monitors state alignment inside the frame loop to catch and sync
--- external option menu changes.
--- @param mapUI ISWorldMap
function AddSatelliteViewToMap.checkTerrainImage(mapUI)
    if mapUI.isTerrainImage ~= mapUI.mapAPI:getBoolean("TerrainImage") then
        AddSatelliteViewToMap.onToggleTerrainImage(mapUI)
    end
end

--- onToggleTerrainImage operates as the core state machine switcher to swap map render
--- styles between satellite files and paper shaders.
--- @param mapUI ISWorldMap
function AddSatelliteViewToMap.onToggleTerrainImage(mapUI)
    mapUI.isTerrainImage = not mapUI.isTerrainImage

    if mapUI.isTerrainImage then
        AddSatelliteViewToMap.showTerrainImage(mapUI)
    else
        MapUtils.initDefaultStyleV3(mapUI)
        MapUtils.overlayPaper(mapUI)
    end

    mapUI.mapAPI:setBoolean("TerrainImage", mapUI.isTerrainImage)
end

--- showTerrainImage rebuilds the map's low-level layout cache by clearing vector graphics
--- and inserting a custom raw texture PyramidLayer.
--- @param mapUI ISWorldMap
function AddSatelliteViewToMap.showTerrainImage(mapUI)
    local styleAPI = mapUI.mapAPI:getStyleAPI()
    styleAPI:clear()

    local pyramidLayer = styleAPI:newPyramidLayer("pyramid")
    pyramidLayer:setPyramidFileName("pyramid.zip")
    pyramidLayer:addFill(0.0, 255.0, 255.0, 255.0, 255.0)

    MapUtils.initDefaultTextLayersV3(mapUI)
end

--- onButtonToggleTerrainImage acts as a click proxy handler to bridge the vanilla button
--- target system into our module scope.
--- @param mapUI ISWorldMap
function AddSatelliteViewToMap.onButtonToggleTerrainImage(mapUI)
    AddSatelliteViewToMap.onToggleTerrainImage(mapUI)
end

--- ISWorldMap_createChildren attaches the custom terrain toggle button directly to the
--- main map window layout.
--- Is hooked function for creating map UI children.
--- @param self ISWorldMap
function AddSatelliteViewToMap.ISWorldMap_createChildren(self)
    AddSatelliteViewToMap.OriginalFunctions.ISWorldMap_createChildren(self)

    if not AddSatelliteViewToMap.IsEnabledOnServer() then
        return
    end

    local btnSize = self.texViewIsometric and self.texViewIsometric:getWidth() or 48

    local btnX = self.buttonPanel:getX() - 10 - btnSize
    local btnY = self.buttonPanel:getY()

    self.terrainBtn2 = ISButton:new(btnX, btnY, btnSize, btnSize, "", self, AddSatelliteViewToMap.onButtonToggleTerrainImage)
    self.terrainBtn2:setImage(self.texViewTerrainImage)
    self:addChild(self.terrainBtn2)

    -- Link the custom button layout into joypad navigation array for gamepad controllers
    if self.buttonPanel.joypadButtons and #self.buttonPanel.joypadButtons > 0 then
        table.insert(self.buttonPanel.joypadButtons, 1, self.terrainBtn2)
    end
end

--- WorldMapOptions_getVisibleOptions re-injects the vanilla "TerrainImage" option back into
--- the visible settings panel.
--- Is hooked option filtering method for map configuration sub-menus.
--- @param self WorldMapOptions
--- @return table
function AddSatelliteViewToMap.WorldMapOptions_getVisibleOptions(self)
    local result = AddSatelliteViewToMap.OriginalFunctions.WorldMapOptions_getVisibleOptions(self)

    if not AddSatelliteViewToMap.IsEnabledOnServer() then
        return result
    end

    -- Iterates through native core API map options to extract the hidden TerrainImage option object
    for i=1, self.map.mapAPI:getOptionCount() do
        local option = self.map.mapAPI:getOptionByIndex(i-1)
        if "TerrainImage" == option:getName() then
            table.insert(result, option)
            break
        end
    end

    -- Sort the returned configuration options by name to maintain UI consistency
    table.sort(result, function(a,b) return not string.sort(a:getName(), b:getName()) end)

    return result
end

--- ISWorldMap_prerender adds terrain image check.
--- Is hooked map prerender sequence that handles per-frame check triggers.
--- @param self ISWorldMap
function AddSatelliteViewToMap.ISWorldMap_prerender(self)
    AddSatelliteViewToMap.OriginalFunctions.ISWorldMap_prerender(self)

    if not AddSatelliteViewToMap.IsEnabledOnServer() then
        return
    end

    AddSatelliteViewToMap.checkTerrainImage(self)
end

--- ISWorldMap_saveSettings writes configuration directly into native WorldMapSettings profiles.
--- is hooked serialization function that persists user map layer states.
--- @param self ISWorldMap
function AddSatelliteViewToMap.ISWorldMap_saveSettings(self)
    AddSatelliteViewToMap.OriginalFunctions.ISWorldMap_saveSettings(self)

    if not AddSatelliteViewToMap.IsEnabledOnServer() then
        return
    end

    local settings = WorldMapSettings.getInstance()
    settings:setBoolean("WorldMap.TerrainImage", self.mapAPI:getBoolean("TerrainImage"))
    settings:save()
end

--- ISWorldMap_restoreSettings syncs internal properties and trigger custom pyramid layer
--- loading if historical state dictates.
--- is hooked initialization/load function that restores historical map view profiles.
--- @param self ISWorldMap
function AddSatelliteViewToMap.ISWorldMap_restoreSettings(self)
    AddSatelliteViewToMap.OriginalFunctions.ISWorldMap_restoreSettings(self)

    if not AddSatelliteViewToMap.IsEnabledOnServer() then
        return
    end

    local settings = WorldMapSettings.getInstance()
    local terrainImage = settings:getBoolean("WorldMap.TerrainImage")

    self.isTerrainImage = terrainImage
    self.mapAPI:setBoolean("TerrainImage", terrainImage)
    if terrainImage then
        AddSatelliteViewToMap.showTerrainImage(self)
    end
end

ISWorldMap.createChildren = AddSatelliteViewToMap.ISWorldMap_createChildren
WorldMapOptions.getVisibleOptions = AddSatelliteViewToMap.WorldMapOptions_getVisibleOptions
ISWorldMap.prerender = AddSatelliteViewToMap.ISWorldMap_prerender
ISWorldMap.saveSettings = AddSatelliteViewToMap.ISWorldMap_saveSettings
ISWorldMap.restoreSettings = AddSatelliteViewToMap.ISWorldMap_restoreSettings
