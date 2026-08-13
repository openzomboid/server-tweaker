--
-- Copyright (c) 2024 Di-crash and outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

if isClient() then return end

local MoreVehicleCommands = {}

MoreVehicleCommands.OnClientCommand = function(module, command, player, args)
    if module == 'vehicle' and command == "setEngineQuality" then
        local vehicle = getVehicleById(args.vehicle);

        if SandboxVars.VehicleEasyUse then
            vehicle:setEngineFeature(args.quality, 30, args.power);
        else
            vehicle:setEngineFeature(args.quality, args.loudness, args.power);
        end

        vehicle:transmitEngine();
        vehicle:updatePartStats();
        vehicle:updateBulletStats();
    end

    if module == 'vehicle' and command == "setTruckRepairs" then
        local vehicle = getVehicleById(args.vehicle);
        local part = vehicle:getPartById(args.part);

        part:getInventoryItem():setHaveBeenRepaired(args.repairs);

        vehicle:updatePartStats();
        vehicle:updateBulletStats();
        vehicle:transmitPartCondition(part);
        vehicle:transmitPartItem(part);
        vehicle:transmitPartModData(part);
    end
end

Events.OnClientCommand.Add(MoreVehicleCommands.OnClientCommand)
