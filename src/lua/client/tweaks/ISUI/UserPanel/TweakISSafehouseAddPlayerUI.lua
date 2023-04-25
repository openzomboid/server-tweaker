--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakISSafehouseAddPlayerUI = {
    Original = {
        drawPlayers = ISSafehouseAddPlayerUI.drawPlayers,
        onClick = ISSafehouseAddPlayerUI.onClick,
    }
}

-- drawPlayers overrides the original ISSafehouseAddPlayerUI:drawPlayers function.
-- Allows admin to add anyone to safehouse.
TweakISSafehouseAddPlayerUI.drawPlayers = function(self, y, item, alt)
    if not SandboxVars.ServerTweaker.AdminsFreeAddToSafehouse then
        TweakISSafehouseAddPlayerUI.Original.drawPlayers(self, y, item, alt)
        return
    end

    local a = 0.9;

    self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b);

    if self.selected == item.index then
        self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15);

        if self.selected == item.index then
            local character = getPlayer();

            if openutils.HasPermission(character, "gm") or not item.tooltip then
                self.parent.addPlayer.enable = true;
                self.parent.selectedPlayer = item.item.username;
            else
                self.parent.addPlayer.tooltip = item.tooltip;
                self.parent.addPlayer.enable = false;
            end
        end
    end

    self:drawText(item.text, 10, y + 2, 1, 1, 1, a, self.font);

    return y + self.itemheight;
end

-- onClick overrides the original ISSafehouseAddPlayerUI:onClick function.
-- Allows admin to add anyone to safehouse.
TweakISSafehouseAddPlayerUI.onClick = function(self, button)
    if button.internal == "ADDPLAYER" then
        if SandboxVars.ServerTweaker.AdminsFreeAddToSafehouse then
            local character = getPlayer();

            if openutils.HasPermission(character, "gm") then
                if self.changeOwnership then
                    local prevOwner = self.safehouse:getOwner()

                    self.safehouse:setOwner(self.selectedPlayer);
                    self.safehouse:addPlayer(prevOwner);
                    self.safehouseUI:populateList();
                    self.safehouse:syncSafehouse();

                    self:setVisible(false);
                    self:removeFromUIManager();
                    ISSafehouseAddPlayerUI.instance = nil
                else
                    self.safehouse:addPlayer(self.selectedPlayer);
                    self.addPlayer.enable = false;
                    self.safehouseUI:populateList();
                    self.safehouse:syncSafehouse();
                end

                return
            end
        end
    end

    TweakISSafehouseAddPlayerUI.Original.onClick(self, button)
end

ISSafehouseAddPlayerUI.drawPlayers = TweakISSafehouseAddPlayerUI.drawPlayers;
ISSafehouseAddPlayerUI.onClick = TweakISSafehouseAddPlayerUI.onClick;
