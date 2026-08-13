--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakWorldMap = {
    Original = {
        createChildren = ISWorldMap.createChildren,
        onRightMouseUp = ISWorldMap.onRightMouseUp,
    }
}

-- createChildren overrides the original ISWorldMap.createChildren function.
-- Allows users to turn on satellite view on world map.
TweakWorldMap.createChildren = function(self)
    TweakWorldMap.Original.createChildren(self)

    local btnSize = self.texViewIsometric and self.texViewIsometric:getWidth() or 48

    if SandboxVars.ServerTweaker.AddSatelliteViewToMap and not getDebug() then
        self.pyramidBtn2 = ISButton:new(self.buttonPanel.joypadButtons[1].x - 20 - btnSize, 0, btnSize, btnSize, "", self, self.onTogglePyramid)
        self.pyramidBtn2:setImage(self.texViewPyramid)
        self.buttonPanel:addChild(self.pyramidBtn2)
        table.insert(self.buttonPanel.joypadButtons, 1, self.pyramidBtn2)
    end
end

-- createChildren overrides the original ISWorldMap.createChildren function.
-- Allows GMs to teleport on world map.
TweakWorldMap.onRightMouseUp = function(self, x, y)
    TweakWorldMap.Original.onRightMouseUp(self, x, y)

    if not (SandboxVars.ServerTweaker.AllowAdminToolsForGM or getAccessLevel() == "moderator") then
        return
    end

    if self.symbolsUI:onRightMouseUpMap(x, y) then
        return true
    end
    if not (getAccessLevel() == "moderator" or getAccessLevel() == "gm") then
        return false
    end
    local playerNum = 0
    local playerObj = getSpecificPlayer(0)
    if not playerObj then return end -- Debug in main menu
    local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())

    local option = context:addOption("Show Cell Grid", self, function(self) self:setShowCellGrid(not self.showCellGrid) end)
    context:setOptionChecked(option, self.showCellGrid)

    option = context:addOption("Show Tile Grid", self, function(self) self:setShowTileGrid(not self.showTileGrid) end)
    context:setOptionChecked(option, self.showTileGrid)

    self.hideUnvisitedAreas = self.mapAPI:getBoolean("HideUnvisited")
    option = context:addOption("Hide Unvisited Areas", self, function(self) self:setHideUnvisitedAreas(not self.hideUnvisitedAreas) end)
    context:setOptionChecked(option, self.hideUnvisitedAreas)

    option = context:addOption("Isometric", self, function(self) self:setIsometric(not self.isometric) end)
    context:setOptionChecked(option, self.isometric)

    -- DEV: Apply the style again after reloading ISMapDefinitions.lua
    --option = context:addOption("Reapply Style", self,
    --        function(self)
    --            MapUtils.initDefaultStyleV1(self)
    --            MapUtils.overlayPaper(self)
    --        end)

    local worldX = self.mapAPI:uiToWorldX(x, y)
    local worldY = self.mapAPI:uiToWorldY(x, y)
    if getWorld():getMetaGrid():isValidChunk(worldX / 10, worldY / 10) then
        option = context:addOption("Teleport Here", self, self.onTeleport, worldX, worldY)
    end

    return true
end

ISWorldMap.createChildren = TweakWorldMap.createChildren;
ISWorldMap.onRightMouseUp = TweakWorldMap.onRightMouseUp;

TweakWorldMapButtonPanel = {
    Original = {
        new = ISWorldMapButtonPanel.new,
    }
}

-- Workaround to satellite view on world map.
-- Adds 72 pixels to ButtonPanel for making extra button work. Otherwise,
-- the button is overlaid and cannot be clicked.
TweakWorldMapButtonPanel.new = function(self, x, y, width, height)
    if SandboxVars.ServerTweaker.AddSatelliteViewToMap and not getDebug() then
        return TweakWorldMapButtonPanel.Original.new(self, x-72, y, width+72, height)
    end

    return TweakWorldMapButtonPanel.Original.new(self, x, y, width, height)
end

ISWorldMapButtonPanel.new = TweakWorldMapButtonPanel.new;
