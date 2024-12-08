--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakAdminContextMenu = {
    Original = {
        doMenu = AdminContextMenu.doMenu,
    }
}

-- doMenu Adds admin context menu to GM users.
TweakAdminContextMenu.doMenu = function(player, context, worldobjects, test)
    if not SandboxVars.ServerTweaker.AllowAdminToolsForGM then
        return
    end

    if not (isClient() and getAccessLevel() == "gm") then return true; end
    if test and ISWorldObjectContextMenu.Test then return true end

    local square = nil;
    for i,v in ipairs(worldobjects) do
        square = v:getSquare();
        break;
    end

    for i=1,square:getObjects():size() do
        table.insert(worldobjects, square:getObjects():get(i-1))
    end
    worldobjects = openutils.RemoveDuplicates(worldobjects)

    local playerObj = getSpecificPlayer(player)

    local debugOption = context:addDebugOption("Tools", worldobjects, nil);
    local subMenu = ISContextMenu:getNew(context);
    context:addSubMenu(debugOption, subMenu);

    subMenu:addOption("Teleport", playerObj, AdminContextMenu.onTeleportUI);
    subMenu:addOption("Remove item tool", playerObj, AdminContextMenu.onRemoveItemTool)
    subMenu:addOption("Spawn Vehicle", playerObj, AdminContextMenu.onSpawnVehicle);
    --subMenu:addOption("Horde Manager", square, AdminContextMenu.onHordeManager, playerObj);
    subMenu:addOption("Trigger Thunder", playerObj, AdminContextMenu.onTriggerThunderUI)

    local noiseOption = subMenu:addOption("Make noise", worldobjects, nil);
    local noiseSubMenu = subMenu:getNew(subMenu);
    subMenu:addSubMenu(noiseOption, noiseSubMenu);

    noiseSubMenu:addOption("Radius: 10", square, AdminContextMenu.onMakeNoise, playerObj, 10, 100);
    noiseSubMenu:addOption("Radius: 20", square, AdminContextMenu.onMakeNoise, playerObj, 20, 100);
    noiseSubMenu:addOption("Radius: 50", square, AdminContextMenu.onMakeNoise, playerObj, 50, 100);
    noiseSubMenu:addOption("Radius: 100", square, AdminContextMenu.onMakeNoise, playerObj, 100, 100);
    noiseSubMenu:addOption("Radius: 200", square, AdminContextMenu.onMakeNoise, playerObj, 200, 100);
    noiseSubMenu:addOption("Radius: 500", square, AdminContextMenu.onMakeNoise, playerObj, 500, 100);

    --subMenu:addOption("Remove all zombies", nil, AdminContextMenu.OnRemoveAllZombiesClient)

    local vehicle = square:getVehicleContainer()
    if vehicle ~= nil then
        local debugVehOption = subMenu:addOption("Vehicle:", worldobjects, nil);
        local vehSubMenu = ISContextMenu:getNew(subMenu);
        context:addSubMenu(debugVehOption, vehSubMenu);

        vehSubMenu:addOption("HSV & Skin UI", playerObj, AdminContextMenu.onDebugColor, vehicle);
        vehSubMenu:addOption("Blood UI", playerObj, AdminContextMenu.onDebugBlood, vehicle);
        vehSubMenu:addOption("Remove", playerObj, ISVehicleMechanics.onCheatRemove, vehicle);
    end

    for _,obj in ipairs(worldobjects) do
        if instanceof(obj, "IsoDoor") or (instanceof(obj, "IsoThumpable") and obj:isDoor()) then
            local doorOption = subMenu:addOption("Door", worldobjects)
            local doorSubMenu = subMenu:getNew(subMenu)
            subMenu:addSubMenu(doorOption, doorSubMenu)

            doorSubMenu:addOption("Get Door Key", worldobjects, AdminContextMenu.OnGetDoorKey, obj, player)
            doorSubMenu:addOption(obj:isLocked() and "Door Unlock" or "Door Lock", worldobjects, AdminContextMenu.OnDoorLock, obj)
            doorSubMenu:addOption(string.format("Set Door Key ID (%d)", obj:getKeyId()), worldobjects, AdminContextMenu.OnSetDoorKeyID, obj)
            doorSubMenu:addOption("Set Door Building Key ID", worldobjects, AdminContextMenu.OnSetDoorKeyIDBuilding, obj)
            doorSubMenu:addOption("Set Door Random Key ID", worldobjects, AdminContextMenu.OnSetDoorKeyIDRandom, obj)
            doorSubMenu:addOption(string.format("Set force lock (%s)", tostring(not obj:getModData().CustomLock)), worldobjects, AdminContextMenu.setForceLockDoor, obj, player)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(TweakAdminContextMenu.doMenu);
