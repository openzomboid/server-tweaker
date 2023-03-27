--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakWorldObjectContextMenu = {
    Original = {
        createMenu = ISWorldObjectContextMenu.createMenu,
    }
}

-- createMenu rewrites original ISWorldObjectContextMenu.createMenu function.
-- Removes trade with player button.
TweakWorldObjectContextMenu.createMenu = function(player, worldobjects, x, y, test)
    local context = TweakWorldObjectContextMenu.Original.createMenu(player, worldobjects, x, y, test)

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

    return context
end

ISWorldObjectContextMenu.createMenu = TweakWorldObjectContextMenu.createMenu;
