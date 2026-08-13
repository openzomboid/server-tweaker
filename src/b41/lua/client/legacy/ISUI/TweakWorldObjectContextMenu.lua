--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakWorldObjectContextMenu = {}

-- tweakContextMenu adds context menu tweaks.
TweakWorldObjectContextMenu.tweakContextMenu = function(player, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return true end

    local character = getSpecificPlayer(player)

    if SandboxVars.ServerTweaker.DisableTradeWithPlayers then
        for i=1, #context.options do
            local option = context.options[i];

            if option and option.onSelect == ISWorldObjectContextMenu.onTrade then
                context:removeOptionByName(option.name)
                break
            end
        end
    end

    if SandboxVars.ServerTweaker.ContextMenuClickedPlayersInvisibleFix and not SandboxVars.ServerTweaker.ContextMenuClickedPlayersSelection then
        local clickedPlayer = nil

        for _, v in ipairs(worldobjects) do
            if v:getSquare() then
                -- help detecting a player by checking nearby squares
                for x1 = v:getSquare():getX()-1, v:getSquare():getX()+1 do
                    for y1 = v:getSquare():getY()-1, v:getSquare():getY()+1 do
                        local sq = getCell():getGridSquare(x1, y1, v:getSquare():getZ());
                        if sq then
                            for i = 0, sq:getMovingObjects():size()-1 do
                                local o = sq:getMovingObjects():get(i)
                                if instanceof(o, "IsoPlayer") and (o ~= character) and o:isInvisible() then
                                    clickedPlayer = o
                                end
                            end
                        end
                    end
                end
            end
        end

        if clickedPlayer then
            for _, option in pairs(context.options) do
                if option and option.name == getText("ContextMenu_Trade", clickedPlayer:getDisplayName()) then
                    context:removeOptionByName(option.name)
                end

                if option and option.name == getText("ContextMenu_Medical_Check") then
                    context:removeOptionByName(option.name)
                end
            end
        end
    end

    if SandboxVars.ServerTweaker.ContextMenuClickedPlayersSelection then
        local options = context:getMenuOptionNames()

        local traders = {}
        local tradeSubMenu = context:getNew(context)

        local patients = {}
        local medicalCheckSubMenu = context:getNew(context)

        for _, option in pairs(options) do
            if option and option.onSelect == ISWorldObjectContextMenu.onTrade then
                option.name = getText('ContextMenu_TradeWithPlayer')
                option.onSelect = nil
                option.notAvailable = false
                option.toolTip = nil

                context:addSubMenu(option, tradeSubMenu)
            end

            if option and option.name == getText("ContextMenu_Medical_Check") then
                option.name = getText('ContextMenu_Medical_Check')
                option.onSelect = nil
                option.notAvailable = false
                option.toolTip = nil

                context:addSubMenu(option, medicalCheckSubMenu)
            end
        end

        for _, v in ipairs(worldobjects) do
            if v:getSquare() then
                -- help detecting a player by checking nearby squares
                for x = v:getSquare():getX() - 1, v:getSquare():getX() + 1 do
                    for y = v:getSquare():getY() - 1, v:getSquare():getY() + 1 do
                        local sq = getCell():getGridSquare(x, y, v:getSquare():getZ())
                        if sq then
                            for i = 0, sq:getMovingObjects():size() - 1 do
                                local clickedPlayer = sq:getMovingObjects():get(i)

                                if TweakWorldObjectContextMenu.CanTradeWith(character, clickedPlayer) and not traders[clickedPlayer:getUsername()] then
                                    traders[clickedPlayer:getUsername()] = clickedPlayer

                                    local optionTrade = tradeSubMenu:addOption(clickedPlayer:getDisplayName(), worldobjects, ISWorldObjectContextMenu.onTrade, character, clickedPlayer)
                                    if (math.abs(character:getX() - clickedPlayer:getX()) > 2 or math.abs(character:getY() - clickedPlayer:getY()) > 2) then
                                        local tooltip = ISWorldObjectContextMenu.addToolTip()
                                        optionTrade.notAvailable = true
                                        tooltip.description = getText("ContextMenu_GetCloserToTrade", clickedPlayer:getDisplayName())
                                        optionTrade.toolTip = tooltip
                                    end
                                end

                                if TweakWorldObjectContextMenu.CanHealPlayer(character, clickedPlayer) and not patients[clickedPlayer:getUsername()] then
                                    patients[clickedPlayer:getUsername()] = clickedPlayer

                                    local optionMedicalCheck = medicalCheckSubMenu:addOption(clickedPlayer:getDisplayName(), worldobjects, ISWorldObjectContextMenu.onMedicalCheck, character, clickedPlayer)
                                    if (math.abs(character:getX() - clickedPlayer:getX()) > 2 or math.abs(character:getY() - clickedPlayer:getY()) > 2) then
                                        local tooltip = ISWorldObjectContextMenu.addToolTip()
                                        optionMedicalCheck.notAvailable = true
                                        tooltip.description = getText("ContextMenu_GetCloser", clickedPlayer:getDisplayName())
                                        optionMedicalCheck.toolTip = tooltip
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if openutils.ObjectLen(traders) == 0 then
            for _, option in pairs(options) do
                if option and option.name == getText('ContextMenu_TradeWithPlayer') then
                    context:removeOptionByName(option.name)
                    break
                end
            end
        end

        if openutils.ObjectLen(patients) == 0 then
            for _, option in pairs(options) do
                if option and option.name == getText('ContextMenu_Medical_Check') then
                    context:removeOptionByName(option.name)
                    break
                end
            end
        end
    end

    if SandboxVars.ServerTweaker.TakeSafehouseLimitations then
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
end

TweakWorldObjectContextMenu.CanTradeWith = function(character, clickedPlayer)
    if not isClient() or SandboxVars.ServerTweaker.DisableTradeWithPlayers then
        return false
    end

    -- You already thade with someone.
    if ISTradingUI.instance and ISTradingUI.instance:isVisible() then
        return false
    end

    if not instanceof(clickedPlayer, "IsoPlayer") or clickedPlayer == character then
        return false
    end

    if clickedPlayer:isAsleep() then
        return false
    end

    if SandboxVars.ServerTweaker.ContextMenuClickedPlayersInvisibleFix and clickedPlayer:isInvisible() then
        return false
    end

    return true
end

TweakWorldObjectContextMenu.CanHealPlayer = function(character, clickedPlayer)
    if not isClient() then
        return false
    end

    if character:HasTrait("Hemophobic") then
        return false
    end

    if not instanceof(clickedPlayer, "IsoPlayer") or clickedPlayer == character then
        return false
    end

    if clickedPlayer:isAsleep() then
        return false
    end

    if SandboxVars.ServerTweaker.ContextMenuClickedPlayersInvisibleFix and clickedPlayer:isInvisible() then
        return false
    end

    return true
end

Events.OnFillWorldObjectContextMenu.Add(TweakWorldObjectContextMenu.tweakContextMenu)