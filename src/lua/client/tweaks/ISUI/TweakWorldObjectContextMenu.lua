--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakWorldObjectContextMenu = {
    Original = {
        createMenu = ISWorldObjectContextMenu.createMenu,
        --onTakeSafeHouse = ISWorldObjectContextMenu.onTakeSafeHouse,
    }
}

-- createMenu rewrites original ISWorldObjectContextMenu.createMenu function.
-- Removes trade with player button.
TweakWorldObjectContextMenu.createMenu = function(player, worldobjects, x, y, test)
    local context = TweakWorldObjectContextMenu.Original.createMenu(player, worldobjects, x, y, test)

    -- Fix for Joypads.
    if context == nil or type(context) == "boolean" then return context end

    if SandboxVars.ServerTweaker.DisableTradeWithPlayers then
        for i=1, #context.options do
            local option = context.options[i];

            if option.onSelect == ISWorldObjectContextMenu.onTrade then
                local tooltip = option.toolTip or ISWorldObjectContextMenu.addToolTip();
                option.notAvailable = true;
                tooltip.description = getText("ContextMenu_NotAvailableOnTheServer");
                option.toolTip = tooltip;
            end
        end
    end

    if SandboxVars.ServerTweaker.TakeSafehouseLimitations then
        local character = getSpecificPlayer(player)

        local object = worldobjects[1];
        local square = object:getSquare()
        local squareTest = clickedSquare

        for i=1, #context.options do
            local option = context.options[i];

            if option.onSelect == ISWorldObjectContextMenu.onTakeSafeHouse then
                if not safehouse and clickedSquare:getBuilding() and clickedSquare:getBuilding():getDef() then
                    local reason = SafeHouse.canBeSafehouse(clickedSquare, character);

                    if reason == "" then
                        reason = openutils.CanBeSafehouse(clickedSquare, character, SandboxVars.ServerTweaker)

                        if reason ~= "" then
                            local toolTip = ISWorldObjectContextMenu.addToolTip();
                            toolTip:setVisible(false);
                            toolTip.description = reason;
                            option.notAvailable = true;
                            option.toolTip = toolTip;
                        end
                    end
                end
            end
        end
    end

    return context
end

ISWorldObjectContextMenu.createMenu = TweakWorldObjectContextMenu.createMenu;
