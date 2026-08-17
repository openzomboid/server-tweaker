--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)

local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

SafezoneCreationTweak = {
    OriginalFunctions = {
        ISAddSafeZoneUI_updateButtons = ISAddSafeZoneUI.updateButtons,
        ISAddSafeZoneUI_prerender = ISAddSafeZoneUI.prerender,
        ISAddSafeZoneUI_initialise = ISAddSafeZoneUI.initialise,
        ISAddSafeZoneUI_onClick = ISAddSafeZoneUI.onClick
    }
}

function SafezoneCreationTweak.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.SafezoneCreationTweaks
end

function SafezoneCreationTweak.OnServerCommand(module, command, args)
    local character = getPlayer()

    if module == "ServerTweaker" and command == "ISAddSafeZoneUI_create" then
        logger.Debug("SafezoneCreationTweak: Receive safehouse creation event from server", args)

        if not args or type(args) ~= "table" then
            return
        end

        openutils.SetSafehouseData(args.title, args.owner, args.members, args.x, args.y, args.w, args.h)
    end
end

-- ISAddSafeZoneUI_updateButtons overrides the original ISAddSafeZoneUI:updateButtons() function.
-- Allows to create safehouse with area=1.
-- Allows to create safehouse to any player.
function SafezoneCreationTweak.ISAddSafeZoneUI_updateButtons(self)
    SafezoneCreationTweak.OriginalFunctions.ISAddSafeZoneUI_updateButtons(self)

    if not SafezoneCreationTweak.IsEnabledOnServer() then
        return
    end

    self.ok.enable = self.size >= 0
        and string.trim(self.ownerEntry:getInternalText()) ~= ""
        and string.trim(self.titleEntry:getInternalText()) ~= ""
        and self.notIntersecting

    if self.ok:isEnabled() then
        self.ok:enableAcceptColor()
    else
        self.ok:enableDisabledColor()
    end
end

-- ISAddSafeZoneUI_prerender overrides the original ISAddSafeZoneUI:prerender() function.
-- Allows to set members in safehouse.
function SafezoneCreationTweak.ISAddSafeZoneUI_prerender(self)
    if not SafezoneCreationTweak.IsEnabledOnServer() then
        SafezoneCreationTweak.OriginalFunctions.ISAddSafeZoneUI_prerender(self)

        return
    end

    local splitPoint = UI_BORDER_SPACING*2 + 1 + math.max(getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PvpZone_StartingPoint")), getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_PvpZone_CurrentPoint")))
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    self:drawText(getText("IGUI_Safezone_Title"), self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, getText("IGUI_Safezone_Title")) / 2), UI_BORDER_SPACING+1, 1,1,1,1, UIFont.Medium);

    local z = UI_BORDER_SPACING*2 + FONT_HGT_MEDIUM + 1;
    self:drawText(getText("IGUI_SafehouseUI_Title"), UI_BORDER_SPACING+1, z+3,1,1,1,1,UIFont.Small);
    self.titleEntry:setY(z);
    self.titleEntry:setX(splitPoint);
    self.titleEntry:setWidth(self.width - splitPoint - UI_BORDER_SPACING - 1);
    self.titleEntry:setHeight(BUTTON_HGT)
    z = z + UI_BORDER_SPACING + BUTTON_HGT;

    self:drawText(getText("IGUI_SafehouseUI_Owner"), UI_BORDER_SPACING+1, z+3,1,1,1,1,UIFont.Small);
    self.ownerEntry:setY(z);
    self.ownerEntry:setX(splitPoint);
    self.ownerEntry:setWidth(self.width - splitPoint - UI_BORDER_SPACING - 1);
    self.ownerEntry:setHeight(BUTTON_HGT)
    z = z + UI_BORDER_SPACING + BUTTON_HGT;

    -- Monkey patch
    self:drawText(getText("IGUI_SafehouseUI_Members"), UI_BORDER_SPACING+1, z+3,1,1,1,1,UIFont.Small);
    self.membersEntry:setY(z);
    self.membersEntry:setX(splitPoint);
    self.membersEntry:setWidth(self.width - splitPoint - UI_BORDER_SPACING - 1);
    self.membersEntry:setHeight(BUTTON_HGT)
    z = z + UI_BORDER_SPACING + BUTTON_HGT
    -- End of monkey patch

    self:drawText(getText("IGUI_PvpZone_StartingPoint"), UI_BORDER_SPACING+1, z+3,1,1,1,1,UIFont.Small);
    self:drawText(math.floor(self.X2) .. " x " .. math.floor(self.Y2), splitPoint, z+3,1,1,1,1,UIFont.Small);
    z = z + UI_BORDER_SPACING + BUTTON_HGT;

    self:drawText(getText("IGUI_PvpZone_CurrentPoint"), UI_BORDER_SPACING+1, z+3,1,1,1,1,UIFont.Small);
    self:drawText(math.floor(self.character:getX()) .. " x " .. math.floor(self.character:getY()), splitPoint, z+3, 1,1,1,1, UIFont.Small);
    z = z + UI_BORDER_SPACING + BUTTON_HGT;

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

    self:drawText(getText("IGUI_PvpZone_CurrentZoneSize"), UI_BORDER_SPACING+1, z+3,1,1,1,1,UIFont.Small);
    self.size = math.floor(self.zonewidth * self.zoneheight);
    self:drawText(self.size .. "", splitPoint, z+3,1,1,1,1,UIFont.Small);

    self:highlightZone(startingX, endX, startingY, endY, self.fullHighlight)

    self.X1, self.Y1 = startingX, startingY;
    self.X2, self.Y2 = endX, endY;

    self:setHeight(z+UI_BORDER_SPACING*4 + BUTTON_HGT*4+1)

    self:checkIfIntersectingAnotherZone();
    self:updateButtons();

    if not self.character:getRole():hasCapability(Capability.CanSetupSafehouses) then
        self:close()
    end
end

-- ISAddSafeZoneUI_initialise overrides the original ISAddSafeZoneUI:initialise() function.
-- Allows to set members in safehouse.
function SafezoneCreationTweak.ISAddSafeZoneUI_initialise(self)
    if not SafezoneCreationTweak.IsEnabledOnServer() then
        SafezoneCreationTweak.OriginalFunctions.ISAddSafeZoneUI_initialise(self)

        return
    end

    ISPanel.initialise(self);

    local btnWid = 100
    local padBottom = UI_BORDER_SPACING+1

    self.cancel = ISButton:new(self:getWidth() - btnWid - UI_BORDER_SPACING-1, self:getHeight() - padBottom - BUTTON_HGT, btnWid, BUTTON_HGT, getText("UI_Cancel"), self, ISAddSafeZoneUI.onClick);
    self.cancel.internal = "CANCEL";
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise();
    self.cancel:instantiate();
    self.cancel:enableCancelColor()
    self:addChild(self.cancel);

    self.ok = ISButton:new(UI_BORDER_SPACING+1, self:getHeight() - padBottom - BUTTON_HGT, btnWid, BUTTON_HGT, getText("IGUI_PvpZone_AddZone"), self, ISAddSafeZoneUI.onClick);
    self.ok.internal = "OK";
    self.ok.anchorTop = false
    self.ok.anchorBottom = true
    self.ok:initialise();
    self.ok:instantiate();
    self.ok:enableDisabledColor()
    self:addChild(self.ok);

    self.startingPoint = ISButton:new(UI_BORDER_SPACING+1, self.ok.y - BUTTON_HGT - UI_BORDER_SPACING, self.width - (UI_BORDER_SPACING+1)*2, BUTTON_HGT, getText("IGUI_PvpZone_RedefineStartingPoint"), self, ISAddSafeZoneUI.onClick);
    self.startingPoint.internal = "STARTINGPOINT";
    self.startingPoint.anchorTop = false
    self.startingPoint.anchorBottom = true
    self.startingPoint:initialise();
    self.startingPoint:instantiate();
    self.startingPoint.borderColor = {r=1, g=1, b=1, a=0.1};
    self:addChild(self.startingPoint);

    self.titleEntry = ISTextEntryBox:new("Safezone #" .. SafeHouse.getSafehouseList():size() + 1, UI_BORDER_SPACING+1, 10, 200, 18);
    self.titleEntry:initialise();
    self.titleEntry:instantiate();
    self:addChild(self.titleEntry);

    self.ownerEntry = ISTextEntryBox:new(self.character:getUsername(), UI_BORDER_SPACING+1, 10, 200, 18);
    self.ownerEntry:initialise();
    self.ownerEntry:instantiate();
    self:addChild(self.ownerEntry);

    -- Monkey patching
    self.membersEntry = ISTextEntryBox:new("", UI_BORDER_SPACING+1, 10, 200, 18)
    self.membersEntry:initialise()
    self.membersEntry:instantiate()
    self:addChild(self.membersEntry)
    -- End monkey patching

    -- Monkey patching again: UI_BORDER_SPACING*8 was UI_BORDER_SPACING*7 and BUTTON_HGT*6 was BUTTON_HGT*5 on original
    self.claimOptions = ISTickBox:new(UI_BORDER_SPACING+1, 1 + UI_BORDER_SPACING*8 + FONT_HGT_MEDIUM + BUTTON_HGT*6, 20, BUTTON_HGT, "", self, ISAddSafeZoneUI.onClickClaimOptions);
    self.claimOptions:initialise();
    self.claimOptions:instantiate();
    self.claimOptions.selected[1] = false;
    self.claimOptions.selected[2] = true;
    self.claimOptions.selected[3] = true;
    self.claimOptions:addOption(getText("IGUI_Safezone_FullHighlight"));

    self:addChild(self.claimOptions);
end

-- ISAddSafeZoneUI_onClick overrides the original ISAddSafeZoneUI:onClick() function.
-- Allows to set members in safehouse.
-- Allows to create safehouse to any player.
function SafezoneCreationTweak.ISAddSafeZoneUI_onClick(self, button)
    if SafezoneCreationTweak.IsEnabledOnServer() and button.internal == "OK" then
        self.creatingZone = false
        self:setVisible(false)
        self:removeFromUIManager()

        -- local _members = self.membersEntry:getInternalText()
        local _members = ""

        local args = {
            x       = math.floor(math.min(self.X1, self.X2)),
            y       = math.floor(math.min(self.Y1, self.Y2)),
            w       = math.floor(math.abs(self.X1 - self.X2) + 1),
            h       = math.floor(math.abs(self.Y1 - self.Y2) + 1),
            owner   = self.ownerEntry:getInternalText(),
            title   = self.titleEntry:getInternalText(),
            members = self.membersEntry:getInternalText()
        }

        sendClientCommand(getPlayer(), 'ServerTweaker', 'ISAddSafeZoneUI_create', args)

        return
    else
        SafezoneCreationTweak.OriginalFunctions.ISAddSafeZoneUI_onClick(self, button)
    end
end

Events.OnServerCommand.Add(SafezoneCreationTweak.OnServerCommand)

ISAddSafeZoneUI.updateButtons = SafezoneCreationTweak.ISAddSafeZoneUI_updateButtons
ISAddSafeZoneUI.prerender = SafezoneCreationTweak.ISAddSafeZoneUI_prerender
ISAddSafeZoneUI.initialise = SafezoneCreationTweak.ISAddSafeZoneUI_initialise
ISAddSafeZoneUI.onClick = SafezoneCreationTweak.ISAddSafeZoneUI_onClick
