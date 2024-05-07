--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakInventoryMenuElements = {}

function TweakInventoryMenuElements.OnFillInventoryObjectContextMenu(player, context, items)
    if not SandboxVars.ServerTweaker.AllowAdminToolsForGM then
        return
    end

    local character = getPlayer()
    local isAdminOrDebug = getCore():getDebug() or isAdmin()

    if not isAdminOrDebug and openutils.HasPermission(character, "gm") then
        for _, v in ipairs(items) do
            local item = instanceof(v, "InventoryItem") and v or v.items[1]
            local invMenu = ISContextManager.getInstance().getInventoryMenu()

            if item:getContainer() == invMenu.inventory and item:getScriptItem():getRecordedMediaCat() then
                local prefix = character:getAccessLevel()

                local parent = context:addOption(prefix .. ": Change recording");
                local subMenu = ISContextMenu:getNew(context);
                context:addSubMenu(parent, subMenu);

                subMenu:addOption("<NONE>", item, TweakInventoryMenuElements.changeRecording, nil);

                local list = getZomboidRadio():getRecordedMedia():getAllMediaForCategory(item:getScriptItem():getRecordedMediaCat());
                for i=0, list:size()-1 do
                    local other = list:get(i);
                    subMenu:addOption(other:getTranslatedItemDisplayName(), item, TweakInventoryMenuElements.changeRecording, other);
                end

                return
            end
        end
    end
end

function TweakInventoryMenuElements.changeRecording(item, other)
    if other == nil then
        item:setRecordedMediaIndexInteger(-1)
        item:getContainer():setDrawDirty(true);
        return
    end

    item:setRecordedMediaData(other);
    item:getContainer():setDrawDirty(true);
end

Events.OnFillInventoryObjectContextMenu.Add(TweakInventoryMenuElements.OnFillInventoryObjectContextMenu)
