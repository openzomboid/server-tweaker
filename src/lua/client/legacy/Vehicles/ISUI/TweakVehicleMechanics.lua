--
-- Copyright (c) 2024 Di-crash and outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--
require "Vehicles/ISUI/ISVehicleMechanics"

TweakVehicleMechanics = {
    Original = {
        doPartContextMenu = ISVehicleMechanics.doPartContextMenu,
        renderPartDetail = ISVehicleMechanics.renderPartDetail
    }
}

function TweakVehicleMechanics.doPartContextMenu(self, part, x, y)
    if not SandboxVars.ServerTweaker.VehicleMechanicsTweaks then
        TweakVehicleMechanics.Original.doPartContextMenu(self, part, x, y);
        return
    end

    if UIManager.getSpeedControls():getCurrentGameSpeed() == 0 then
        return;
    end

    local playerObj = getSpecificPlayer(self.playerNum);

    if playerObj:getVehicle() ~= nil and not (isDebugEnabled() or (isClient() and (isAdmin() or getAccessLevel() == "moderator"))) then
        return;
    end

    if not self.context then
        self.context = ISContextMenu.get(self.playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY());
    end

    local option;

    TweakVehicleMechanics.Original.doPartContextMenu(self, part, x, y);

    if ISVehicleMechanics.cheat or playerObj:getAccessLevel() ~= "None" then
        if part:getId() == "Engine" then
            option = self.context:addOption("CHEAT: Set Engine Quality", playerObj, TweakVehicleMechanics.onCheatSetEngineQuality, part);
        end

        if part:getId() == "TruckBed" or part:getId() == "TruckBedOpen" then
            option = self.context:addOption("CHEAT: Set Truck Repairs", playerObj, TweakVehicleMechanics.onCheatSetTruckRepairs, part);
        end
    end

    if self.context.numOptions == 1 then
        self.context:setVisible(false);
    else
        self.context:setVisible(true);
    end

    if JoypadState.players[self.playerNum+1] and self.context:getIsVisible() then
        self.context.mouseOver = 1;
        self.context.origin = self;
        JoypadState.players[self.playerNum+1].focus = self.context;

        updateJoypadFocus(JoypadState.players[self.playerNum+1]);
    end
end

function TweakVehicleMechanics.onCheatSetEngineQuality(playerObj, part)
    local vehicle = part:getVehicle();

    local modal = ISTextBox:new(0, 0, 280, 180, "Quality (0-100):", tostring(vehicle:getEngineQuality()),
            nil, TweakVehicleMechanics.onCheatSetEngineQualityAux, playerObj:getPlayerNum(), playerObj, part);

    modal:initialise();
    modal:addToUIManager();
end

function TweakVehicleMechanics.onCheatSetEngineQualityAux(target, button, playerObj, part)
    if button.internal ~= "OK" then
        return;
    end

    local text = button.parent.entry:getText();
    local quality = tonumber(text);

    if not quality then
        return;
    end

    quality = math.max(quality, 0);
    quality = math.min(quality, 100);

    local vehicle = part:getVehicle();
    local qualityBoosted = quality * 1.6;

    if quality * 1.6 > 100 then
        qualityBoosted = 100;
    end

    local qualityModifier = math.max(0.6, ((qualityBoosted) / 100));
    local loudness = vehicle:getScript():getEngineLoudness() or 100;
    loudness = loudness * (SandboxVars.ZombieAttractionMultiplier or 1);
    local power = vehicle:getScript():getEngineForce() * qualityModifier;

    sendClientCommand(playerObj, "vehicle", "setEngineQuality", { vehicle = vehicle:getId(), quality = quality, loudness = loudness, power = power });
end

function TweakVehicleMechanics.onCheatSetTruckRepairs(playerObj, part)
    local repairs

    local modal = ISTextBox:new(0, 0, 280, 180, "Repairs (0-100):", tostring(part:getInventoryItem():getHaveBeenRepaired() - 1),
            nil, TweakVehicleMechanics.onCheatSetTruckRepairsAux, playerObj:getPlayerNum(), playerObj, part);

    modal:initialise();
    modal:addToUIManager();
end

function TweakVehicleMechanics.onCheatSetTruckRepairsAux(target, button, playerObj, part)
    if button.internal ~= "OK" then
        return;
    end

    local text = button.parent.entry:getText();
    local repairs = tonumber(text);

    if not repairs then
        return;
    end

    repairs = repairs + 1;
    repairs = math.max(repairs, 1);
    repairs = math.min(repairs, 101);

    sendClientCommand(playerObj, "vehicle", "setTruckRepairs", { vehicle = part:getVehicle():getId(), part = part:getId(), repairs = repairs });
end

function TweakVehicleMechanics.renderPartDetail(self, part)
    TweakVehicleMechanics.Original.renderPartDetail(self, part);

    if not SandboxVars.ServerTweaker.VehicleMechanicsTweaks then
        return
    end

    local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);
    local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium);

    local y = self:titleBarHeight() + 10 + FONT_HGT_MEDIUM + 5;
    local x = self.xCarTexOffset + (self.width - 10 - self.xCarTexOffset) / 2;
    local lineHgt = FONT_HGT_SMALL;

    if part:getId() == "TruckBed" or part:getId() == "TruckBedOpen" then
        self:drawText(getText("IGUI_Vehicle_TruckRepairs") .. part:getInventoryItem():getHaveBeenRepaired() - 1, x, y + lineHgt, 1, 1, 1, 1);
    end
end

ISVehicleMechanics.doPartContextMenu = TweakVehicleMechanics.doPartContextMenu;
ISVehicleMechanics.renderPartDetail = TweakVehicleMechanics.renderPartDetail;
