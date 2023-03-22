--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

-- WARNING: Monkey Patching!
-- Base game functions are copyrighted to Project Zomboid authors.
-- TODO: Refactor me and remove monkey patching.

TweakAddSafeZoneUI = {
    Original = {
        checkIfAdmin = ISAddSafeZoneUI.checkIfAdmin,
        updateButtons = ISAddSafeZoneUI.updateButtons,
        prerender = ISAddSafeZoneUI.prerender,
        initialise = ISAddSafeZoneUI.initialise,
        onClick = ISAddSafeZoneUI.onClick,
    }
}

-- checkIfAdmin overrides the original ISAddSafeZoneUI:updateButtons() function.
-- Allows to create safehouse by Moderator.
TweakAddSafeZoneUI.checkIfAdmin = function(self)
    if not SandboxVars.ServerTweaker.CustomSafezoneAdminTweaks then
        TweakAddSafeZoneUI.Original.checkIfAdmin(self)
        return
    end

    if self.character:getAccessLevel() ~= "Admin" and self.character:getAccessLevel() ~= "Moderator" then self:close(); end;
end

-- updateButtons overrides the original ISAddSafeZoneUI:updateButtons() function.
-- Allows to create safehouse with area=1.
-- Allows to create safehouse by Moderator.
TweakAddSafeZoneUI.updateButtons = function(self)
    if not SandboxVars.ServerTweaker.CustomSafezoneAdminTweaks then
        TweakAddSafeZoneUI.Original.updateButtons(self)
        return
    end

    self.ok.enable = self.size >= 0
        and string.trim(self.ownerEntry:getInternalText()) ~= ""
        and string.trim(self.titleEntry:getInternalText()) ~= ""
        and self.notIntersecting
        and (self.character:getAccessLevel() == "Admin" or self.character:getAccessLevel() == "Moderator");
end

-- prerender overrides the original ISAddSafeZoneUI:prerender() function.
-- Fixes ZoneSize calculation.
-- Adds possibility to set members in custom safezone creation interface.
TweakAddSafeZoneUI.prerender = function(self)
    if not SandboxVars.ServerTweaker.CustomSafezoneAdminTweaks then
        TweakAddSafeZoneUI.Original.prerender(self)
        return
    end

    local z = 10;
    local splitPoint = self.width / 2;
    local x = 10;
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_Safezone_Title"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_Safezone_Title")) / 2), z, 1,1,1,1, UIFont.Medium);

    z = z + 30;
    self:drawText(getText("IGUI_SafehouseUI_Title"), x, z,1,1,1,1,UIFont.Small);
    self.titleEntry:setY(z + 3);
    self.titleEntry:setX(splitPoint);
    self.titleEntry:setWidth(splitPoint - 10);

    z = z + 30;
    self:drawText(getText("IGUI_SafehouseUI_Owner"), x, z,1,1,1,1,UIFont.Small);
    self.ownerEntry:setY(z + 3);
    self.ownerEntry:setX(splitPoint);
    self.ownerEntry:setWidth(splitPoint - 10);

    z = z + 30;
    self:drawText(getText("IGUI_SafehouseUI_Members"), x, z,1,1,1,1,UIFont.Small);
    self.membersEntry:setY(z + 3);
    self.membersEntry:setX(splitPoint);
    self.membersEntry:setWidth(splitPoint - 10);

    z = z + 30;
    self:drawText(getText("IGUI_PvpZone_StartingPoint"), x, z,1,1,1,1,UIFont.Small);
    self:drawText(math.floor(self.X1) .. " x " .. math.floor(self.Y1), splitPoint, z,1,1,1,1,UIFont.Small);
    z = z + 30;

    self:drawText(getText("IGUI_PvpZone_CurrentPoint"), x, z,1,1,1,1,UIFont.Small);
    self:drawText(math.floor(self.character:getX()) .. " x " .. math.floor(self.character:getY()), splitPoint, z, 1,1,1,1, UIFont.Small);
    z = z + 30;

    local startingX = math.floor(self.startingX);
    local startingY = math.floor(self.startingY);
    local endX = math.floor(self.character:getX());
    local endY = math.floor(self.character:getY());

    if startingX > endX then
        local x2 = endX;
        endX = startingX;
        startingX = x2;
    end
    if startingY > endY then
        local y2 = endY;
        endY = startingY;
        startingY = y2;
    end

    local bwidth = math.abs(startingX - endX) * 2;
    local bheight = math.abs(startingY - endY) * 2;
    self.zonewidth = math.abs(startingX - endX);
    self.zoneheight = math.abs(startingY - endY);

    self:drawText(getText("IGUI_PvpZone_CurrentZoneSize"), x, z,1,1,1,1,UIFont.Small);
    self.size = math.floor((self.zonewidth + 1) * (self.zoneheight + 1));
    self:drawText(self.size .. "", splitPoint, z,1,1,1,1,UIFont.Small);
    z = z + 30;

    self:drawText("X1: " .. self.X1 .. "     Y1: " .. self.Y1, splitPoint, z, 1,1,1,1, UIFont.Small);
    z = z + 30;
    self:drawText("X2: " .. self.X2 .. "     Y2: " .. self.Y2, splitPoint, z, 1,1,1,1, UIFont.Small);
    z = z + 30;

    self:highlightZone(startingX, endX, startingY, endY, self.fullHighlight)

    self.X1, self.Y1 = startingX, startingY;
    self.X2, self.Y2 = endX, endY;

    self:checkIfIntersectingAnotherZone();
    self:updateButtons();
    self:checkIfAdmin();
end

-- initialise overrides the original ISAddSafeZoneUI:initialise() function.
-- Allows to create safehouse by Moderator.
-- Adds possibility to set members in custom safezone creation interface.
TweakAddSafeZoneUI.initialise = function(self)
    if not SandboxVars.ServerTweaker.CustomSafezoneAdminTweaks then
        TweakAddSafeZoneUI.Original.initialise(self)
        return
    end

    ISPanel.initialise(self);
    if self.character:getAccessLevel() ~= "Admin" and self.character:getAccessLevel() ~= "Moderator" then self:close(); return; end;

    local btnWid = 100
    local btnHgt = 25
    local btnHgt2 = 18
    local padBottom = 10

    --btnWid = getTextManager():MeasureStringX(UIFont.Medium, getText("UI_Cancel")) + 20;
    btnWid = 100;
    self.cancel = ISButton:new(self:getWidth() - btnWid - 10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("UI_Cancel"), self, ISAddSafeZoneUI.onClick);
    self.cancel.internal = "CANCEL";
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.cancel);

    --btnWid = getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_PvpZone_AddZone")) + 20;
    btnWid = 100;
    self.ok = ISButton:new(10, self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_PvpZone_AddZone"), self, ISAddSafeZoneUI.onClick);
    self.ok.internal = "OK";
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise();
    self.ok:instantiate();
    self.ok.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.ok);

    btnWid = getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_PvpZone_RedefineStartingPoint")) + 20;
    self.startingPoint = ISButton:new((self.width/2) - (btnWid/2), self:getHeight() - padBottom - btnHgt, btnWid, btnHgt, getText("IGUI_PvpZone_RedefineStartingPoint"), self, ISAddSafeZoneUI.onClick);
    self.startingPoint.internal = "STARTINGPOINT";
    self.startingPoint.anchorTop = false
    self.startingPoint.anchorBottom = true
    self.startingPoint:initialise();
    self.startingPoint:instantiate();
    self.startingPoint.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.startingPoint);

    self.titleEntry = ISTextEntryBox:new("Safezone #" .. SafeHouse.getSafehouseList():size() + 1, 10, 10, 200, 18);
    self.titleEntry:initialise();
    self.titleEntry:instantiate();
    self:addChild(self.titleEntry);

    self.ownerEntry = ISTextEntryBox:new(self.character:getUsername(), 10, 10, 200, 18);
    self.ownerEntry:initialise();
    self.ownerEntry:instantiate();
    self:addChild(self.ownerEntry);

    self.membersEntry = ISTextEntryBox:new("", 10, 10, 200, 18);
    self.membersEntry:initialise();
    self.membersEntry:instantiate();
    self:addChild(self.membersEntry);

    self.claimOptions = ISTickBox:new(10, 270, 20, 18, "", self, ISAddSafeZoneUI.onClickClaimOptions);
    self.claimOptions:initialise();
    self.claimOptions:instantiate();
    self.claimOptions.selected[1] = false;
    self.claimOptions.selected[2] = true;
    self.claimOptions.selected[3] = true;
    self.claimOptions:addOption(getText("IGUI_Safezone_FullHighlight"));

    self:addChild(self.claimOptions);
end

-- onClick overrides the original ISAddSafeZoneUI:onClick() function.
-- Adds possibility to set members in custom safezone creation interface.
TweakAddSafeZoneUI.onClick = function(self, button)
    if not SandboxVars.ServerTweaker.CustomSafezoneAdminTweaks then
        TweakAddSafeZoneUI.Original.onClick(self, button)
        return
    end

    if button.internal == "OK" then
        self.creatingZone = false;
        self:setVisible(false);
        self:removeFromUIManager();
        local setX = math.floor(math.min(self.X1, self.X2));
        local setY = math.floor(math.min(self.Y1, self.Y2));
        local setW = math.floor(math.abs(self.X1 - self.X2) + 1);
        local setH = math.floor(math.abs(self.Y1 - self.Y2) + 1);
        openutils.SetSafehouseData(self.titleEntry:getInternalText(), self.ownerEntry:getInternalText(), self.membersEntry:getInternalText(), setX, setY, setW, setH)
        return;
    end
    if button.internal == "STARTINGPOINT" then
        self:redefineStartingPoint();
    end;
    if button.internal == "CANCEL" then
        self.creatingZone = false;
        self:setVisible(false);
        self:removeFromUIManager();
        return;
    end;
end

ISAddSafeZoneUI.checkIfAdmin = TweakAddSafeZoneUI.checkIfAdmin;
ISAddSafeZoneUI.updateButtons = TweakAddSafeZoneUI.updateButtons;
ISAddSafeZoneUI.prerender = TweakAddSafeZoneUI.prerender;
ISAddSafeZoneUI.initialise = TweakAddSafeZoneUI.initialise;
ISAddSafeZoneUI.onClick = TweakAddSafeZoneUI.onClick;
