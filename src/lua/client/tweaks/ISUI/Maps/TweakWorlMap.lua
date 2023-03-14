--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

-- WARNING: Monkey Patching!
-- Base game functions are copyrighted to Project Zomboid authors.
-- TODO: Refactor me and remove monkey pathing.

TweakWorldMap = {
    Original = {
        createChildren = ISWorldMap.createChildren,
        onRightMouseUp = ISWorldMap.onRightMouseUp,
    }
}

-- createChildren overrides the original ISWorldMap.createChildren function.
-- Allows users to turn on satellite view on map.
TweakWorldMap.createChildren = function(self)
    local symbolsWidth = ISWorldMapSymbols.RequiredWidth()
    self.symbolsUI = ISWorldMapSymbols:new(self.width - 20 - symbolsWidth, 20, symbolsWidth, self.height - 40 * 2, self)
    self.symbolsUI:initialise()
    self.symbolsUI:setAnchorLeft(false)
    self.symbolsUI:setAnchorRight(true)
    self:addChild(self.symbolsUI)

    local btnSize = self.texViewIsometric and self.texViewIsometric:getWidth() or 48
    local btnCount = 6
    if getDebug() then
        btnCount = btnCount + 1
    end

    self.buttonPanel = ISWorldMapButtonPanel:new(self.width - 20 - (btnSize * btnCount + 20 * (btnCount - 1)), self.height - 20 - btnSize, btnSize * btnCount + 20 * (btnCount - 1), btnSize)
    self.buttonPanel.anchorLeft = false
    self.buttonPanel.anchorRight = true
    self.buttonPanel.anchorTop = false
    self.buttonPanel.anchorBottom = true
    self:addChild(self.buttonPanel)

    local buttons = {}

    self.closeBtn = ISButton:new(self.buttonPanel.width - btnSize, 0, btnSize, btnSize, "X", self, self.close)
    self.buttonPanel:addChild(self.closeBtn)
    table.insert(buttons, 1, self.closeBtn)

    self.forgetBtn = ISButton:new(buttons[1].x - 20 - btnSize, 0, btnSize, btnSize, "?", self, function(self, button) self:onForget(button) end)
    self.buttonPanel:addChild(self.forgetBtn)
    table.insert(buttons, 1, self.forgetBtn)

    self.symbolsBtn = ISButton:new(buttons[1].x - 20 - btnSize, 0, btnSize, btnSize, "S", self, self.onToggleSymbols)
    self.buttonPanel:addChild(self.symbolsBtn)
    table.insert(buttons, 1, self.symbolsBtn)

    self.centerBtn = ISButton:new(buttons[1].x - 20 - btnSize, 0, btnSize, btnSize, "C", self, self.onCenterOnPlayer)
    self.buttonPanel:addChild(self.centerBtn)
    table.insert(buttons, 1, self.centerBtn)

    self.perspectiveBtn = ISButton:new(buttons[1].x - 20 - btnSize, 0, btnSize, btnSize, "", self, self.onChangePerspective)
    self.perspectiveBtn:setImage(self.isometric and self.texViewIsometric or self.texViewOrthographic)
    self.buttonPanel:addChild(self.perspectiveBtn)
    table.insert(buttons, 1, self.perspectiveBtn)

    --if getDebug() then
        self.pyramidBtn = ISButton:new(buttons[1].x - 20 - btnSize, 0, btnSize, btnSize, "", self, self.onTogglePyramid)
        self.pyramidBtn:setImage(self.texViewPyramid)
        self.buttonPanel:addChild(self.pyramidBtn)
        table.insert(buttons, 1, self.pyramidBtn)
    --end

    self.optionBtn = ISButton:new(buttons[1].x - 20 - btnSize, 0, btnSize, btnSize, "OPT", self, self.onChangeOptions)
    self.buttonPanel:addChild(self.optionBtn)
    table.insert(buttons, 1, self.optionBtn)

    self.buttonPanel:insertNewListOfButtons(buttons)
    self.buttonPanel.joypadIndex = 1
    self.buttonPanel.joypadIndexY = 1
end

-- createChildren overrides the original ISWorldMap.createChildren function.
-- Allows GMs to teleport on the map.
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
