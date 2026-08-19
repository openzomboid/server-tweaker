--
-- Copyright (c) 2026 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

-- ElevatedStaffPermissions manages administrative map tools and interactions for non-admin staff roles.
-- This class extends world map context menus, enabling moderators and game masters to access specific
-- grid rendering layers and coordinates teleportation functions when enabled by the server configuration.
ElevatedStaffPermissions = {
    OriginalFunctions = {
        ISWorldMap_onRightMouseUp = ISWorldMap.onRightMouseUp
    }
}

-- IsEnabledOnServer checks if the elevated staff permission modifications are currently enabled.
-- It queries the global sandbox variable structure to determine if the server allows non-admin
-- staff (moderators, gms) extensions.
function ElevatedStaffPermissions.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.ElevatedStaffPermissions
end

function ElevatedStaffPermissions.ISWorldMap_onRightMouseUp(self, x, y)
    if not ElevatedStaffPermissions.IsEnabledOnServer() then
        return ElevatedStaffPermissions.OriginalFunctions.ISWorldMap_onRightMouseUp(self, x, y)
    end

    if getDebug() or getAccessLevel() == "admin" then
        return ElevatedStaffPermissions.OriginalFunctions.ISWorldMap_onRightMouseUp(self, x, y)
    end

    if self.symbolsUI:onRightMouseUpMap(x, y) then
        return true
    end
    
    local playerNum = 0
    local character = getSpecificPlayer(0)
    if not character then return end -- Debug in main menu

    local role = character:getRole()
    if not role then
        return ElevatedStaffPermissions.OriginalFunctions.ISWorldMap_onRightMouseUp(self, x, y)
    end

    if not role:hasCapability(Capability.SeeWorldMap) then
        return ElevatedStaffPermissions.OriginalFunctions.ISWorldMap_onRightMouseUp(self, x, y)
    end

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

    if role:hasCapability(Capability.TeleportToCoordinates) then
        local worldX = self.mapAPI:uiToWorldX(x, y)
        local worldY = self.mapAPI:uiToWorldY(x, y)
        if getWorld():getMetaGrid():isValidChunk(worldX / 10, worldY / 10) then
            option = context:addOption(getText("IGUI_ZombiePopulation_TeleportHere"), self, self.onTeleport, worldX, worldY)
        end
    end

    return true
end

ISWorldMap.onRightMouseUp = ElevatedStaffPermissions.ISWorldMap_onRightMouseUp
