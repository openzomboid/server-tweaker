--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

-- WARNING: Monkey Patching!
-- Base game functions are copyrighted to Project Zomboid authors.
-- TODO: Refactor me and remove monkey patching.

TweakSafehouseUI = {
    Original = {
        initialise = ISSafehouseUI.initialise
    }
}

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

-- initialise overrides the original ISSafehouseUI:initialise() function.
-- Adds safehouse size.
TweakSafehouseUI.initialise = function(self)
    -- TweakSafehouseUI.Original.initialise(self)

    ISPanel.initialise(self);
    local btnWid = 100
    local btnHgt = math.max(25, FONT_HGT_SMALL + 3 * 2)
    local btnHgt2 = FONT_HGT_SMALL
    local padBottom = 10

    self.no = ISButton:new(self:getWidth() - btnWid - 10, 0, btnWid, btnHgt, getText("UI_Ok"), self, ISSafehouseUI.onClick);
    self.no.internal = "OK";
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.no);

    local nameLbl = ISLabel:new(10, 20, FONT_HGT_SMALL, getText("IGUI_SafehouseUI_Title"), 1, 1, 1, 1, UIFont.Small, true)
    nameLbl:initialise()
    nameLbl:instantiate()
    self:addChild(nameLbl)

    self.title = ISLabel:new(nameLbl:getRight() + 8, nameLbl.y, FONT_HGT_SMALL, self.safehouse:getTitle(), 0.6, 0.6, 0.8, 1.0, UIFont.Small, true)
    self.title:initialise()
    self.title:instantiate()
    self:addChild(self.title)

    self.changeTitle = ISButton:new(0, nameLbl.y, 70, btnHgt2, getText("IGUI_PlayerStats_Change"), self, ISSafehouseUI.onClick);
    self.changeTitle.internal = "CHANGETITLE";
    self.changeTitle:initialise();
    self.changeTitle:instantiate();
    self.changeTitle.borderColor = self.buttonBorderColor;
    self:addChild(self.changeTitle);

    local ownerLbl = ISLabel:new(10, nameLbl:getBottom() + 10, FONT_HGT_SMALL, getText("IGUI_SafehouseUI_Owner"), 1, 1, 1, 1, UIFont.Small, true)
    ownerLbl:initialise()
    ownerLbl:instantiate()
    self:addChild(ownerLbl)

    self.owner = ISLabel:new(ownerLbl:getRight() + 8, ownerLbl.y, FONT_HGT_SMALL, "", 0.6, 0.6, 0.8, 1.0, UIFont.Small, true)
    self.owner:initialise()
    self.owner:instantiate()
    self:addChild(self.owner)

    local posLbl = ISLabel:new(10, ownerLbl:getBottom() + 7, FONT_HGT_SMALL, getText("IGUI_SafehouseUI_Pos"), 1, 1, 1, 1, UIFont.Small, true)
    posLbl:initialise()
    posLbl:instantiate()
    self:addChild(posLbl)

    self.pos = ISLabel:new(posLbl:getRight() + 8, posLbl.y, FONT_HGT_SMALL, getText("IGUI_SafehouseUI_Pos2", self.safehouse:getX(), self.safehouse:getY()), 0.6, 0.6, 0.8, 1.0, UIFont.Small, true)
    self.pos:initialise()
    self.pos:instantiate()
    self:addChild(self.pos)

    -- Monkey patch 1: Add safehouse size.
    local areaLbl = ISLabel:new(10, posLbl:getBottom() + 7, FONT_HGT_SMALL, getText("IGUI_SafehouseUI_Area"), 1, 1, 1, 1, UIFont.Small, true)
    if SandboxVars.ServerTweaker.DisplaySafehouseAreaSize then
        areaLbl:initialise()
        areaLbl:instantiate()
        self:addChild(areaLbl)

        local squareValue = self.safehouse:getW() * self.safehouse:getH()

        self.area = ISLabel:new(areaLbl:getRight() + 8, areaLbl.y, FONT_HGT_SMALL, tostring(squareValue), 0.6, 0.6, 0.8, 1.0, UIFont.Small, true)
        self.area:instantiate()
        self:addChild(self.area)
    end

    self.releaseSafehouse = ISButton:new(10, 0, 70, btnHgt, getText("IGUI_SafehouseUI_Release"), self, ISSafehouseUI.onClick);
    self.releaseSafehouse.internal = "RELEASE";
    self.releaseSafehouse:initialise();
    self.releaseSafehouse:instantiate();
    self.releaseSafehouse.borderColor = self.buttonBorderColor;
    self:addChild(self.releaseSafehouse);
    self.releaseSafehouse.parent = self;
    self.releaseSafehouse:setVisible(false);

    self.changeOwnership = ISButton:new(0, ownerLbl.y, 70, btnHgt2, getText("IGUI_SafehouseUI_ChangeOwnership"), self, ISSafehouseUI.onClick);
    self.changeOwnership.internal = "CHANGEOWNERSHIP";
    self.changeOwnership:initialise();
    self.changeOwnership:instantiate();
    self.changeOwnership.borderColor = self.buttonBorderColor;
    self:addChild(self.changeOwnership);
    self.changeOwnership.parent = self;
    self.changeOwnership:setVisible(false);

    -- Monkey patch 2: Continue to add safehouse size.
    local playersLblBottom = posLbl:getBottom() + 20
    if SandboxVars.ServerTweaker.DisplaySafehouseAreaSize then
        playersLblBottom = areaLbl:getBottom() + 25
    end

    local playersLbl = ISLabel:new(10, playersLblBottom, FONT_HGT_SMALL, getText("IGUI_SafehouseUI_Players"), 1, 1, 1, 1, UIFont.Small, true)
    playersLbl:initialise()
    playersLbl:instantiate()
    self:addChild(playersLbl)

    self.refreshPlayerList = ISButton:new(playersLbl:getRight() + 20, playersLbl.y, 70, btnHgt2, getText("UI_servers_refresh"), self, ISSafehouseUI.onClick);
    self.refreshPlayerList.internal = "REFRESHLIST";
    self.refreshPlayerList:initialise();
    self.refreshPlayerList:instantiate();
    self.refreshPlayerList.borderColor = self.buttonBorderColor;
    self:addChild(self.refreshPlayerList);

    self.playerList = ISScrollingListBox:new(10, playersLbl:getBottom() + 5, self.width - 20, (FONT_HGT_SMALL + 2 * 2) * 8);
    self.playerList:initialise();
    self.playerList:instantiate();
    self.playerList.itemheight = FONT_HGT_SMALL + 2 * 2;
    self.playerList.selected = 0;
    self.playerList.joypadParent = self;
    self.playerList.font = UIFont.NewSmall;
    self.playerList.doDrawItem = self.drawPlayers;
    self.playerList.drawBorder = true;
    self:addChild(self.playerList);

    self.removePlayer = ISButton:new(0, self.playerList.y + self.playerList.height + 5, 70, btnHgt2, getText("ContextMenu_Remove"), self, ISSafehouseUI.onClick);
    self.removePlayer.internal = "REMOVEPLAYER";
    self.removePlayer:initialise();
    self.removePlayer:instantiate();
    self.removePlayer.borderColor = self.buttonBorderColor;
    self.removePlayer:setWidthToTitle(70)
    self.removePlayer:setX(self.playerList:getRight() - self.removePlayer.width)
    self:addChild(self.removePlayer);
    self.removePlayer.enable = false;
    self.removePlayer:setVisible(self:isOwner() or self:hasPrivilegedAccessLevel());

    self.quitSafehouse = ISButton:new(0, self.playerList.y + self.playerList.height + 5, 70, btnHgt2, getText("IGUI_SafehouseUI_QuitSafehouse"), self, ISSafehouseUI.onClick);
    self.quitSafehouse.internal = "QUITSAFE";
    self.quitSafehouse:initialise();
    self.quitSafehouse:instantiate();
    self.quitSafehouse.borderColor = self.buttonBorderColor;
    self.quitSafehouse:setWidthToTitle(70)
    self.quitSafehouse:setX(self.playerList:getRight() - self.quitSafehouse.width)
    if self:hasPrivilegedAccessLevel() then
        self.quitSafehouse:setY(self.removePlayer.y + btnHgt2 + 5)
    end
    self:addChild(self.quitSafehouse);
    self.quitSafehouse:setVisible(not self:isOwner() and self.safehouse:getPlayers():contains(self.player:getUsername()));

    self.addPlayer = ISButton:new(self.playerList.x, self.playerList.y + self.playerList.height + 5, 70, btnHgt2, getText("IGUI_SafehouseUI_AddPlayer"), self, ISSafehouseUI.onClick);
    self.addPlayer.internal = "ADDPLAYER";
    self.addPlayer:initialise();
    self.addPlayer:instantiate();
    self.addPlayer.borderColor = self.buttonBorderColor;
    self:addChild(self.addPlayer);

    self.respawn = ISTickBox:new(10, self.addPlayer:getBottom() + 10, getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_SafehouseUI_Respawn")) + 20, 18, "", self, ISSafehouseUI.onClickRespawn);
    self.respawn:initialise();
    self.respawn:instantiate();
    self.respawn.selected[1] = self.safehouse:isRespawnInSafehouse(self.player:getUsername());
    self.respawn:addOption(getText("IGUI_SafehouseUI_Respawn"));
    self:addChild(self.respawn);
    self.respawn.safehouseUI = self;
    if not getServerOptions():getBoolean("SafehouseAllowRespawn") then
        self.respawn.enable = false;
    end

    self.no:setY(self.respawn:getBottom() + 20)
    self.releaseSafehouse:setY(self.respawn:getBottom() + 20)
    self:setHeight(self.no:getBottom() + padBottom)

    self:populateList();

end

ISSafehouseUI.initialise = TweakSafehouseUI.initialise;
