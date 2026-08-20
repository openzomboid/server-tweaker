--
-- Copyright (c) 2026 outdead and James "J" Kelly.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

BrushToolFixServer = {}

-- onClientCommand intercepts incoming network commands from clients to securely execute brush tool building routines.
-- It validates the packet payloads, performs server-side duplicate sprite checks, dynamically instantiates empty grid
-- squares if necessary, and spawns synched IsoObject elements across all connected clients.
function BrushToolFixServer.onClientCommand(module, command, character, args)
    if not character then return end

    if module == "ServerTweaker" and command == "BrushToolFix_create" then
        if not args or type(args) ~= "table" then
            logger.Debug("BrushToolFixServer.onClientCommand: invalid args")
            return
        end

        local tileAlreadyOnSquare = false
        local spriteName = tostring(args.sprite or "")
        local cell = getWorld():getCell()
        local square = cell:getGridSquare(args.x, args.y, args.z)

        if square == nil and getWorld():isValidSquare(args.x, args.y, args.z) then
            square = cell:createNewGridSquare(args.x, args.y, args.z, true)
        end

        if not square then
            logger.Debug("BrushToolFixServer.onClientCommand: square is empty")
            return
        end

        local objs = square:getObjects()

        for i = 0, objs:size() - 1 do
            local sprite = objs:get(i):getSprite()

            if sprite and sprite:getName() == spriteName then
                tileAlreadyOnSquare = true
                break
            end
        end

        if tileAlreadyOnSquare then
            logger.Debug("BrushToolFixServer.onClientCommand: tile already on square")
        else
            local tempObj = IsoObject.new(square, spriteName)
            local props = ISMoveableSpriteProps.new(tempObj:getSprite())
            props.rawWeight = 10
            props:placeMoveableInternal(square, instanceItem("Base.Plank"), spriteName)

            -- Sync with clients
            local newObjs = square:getObjects()
            if newObjs:size() > 0 then
                local placedObj = newObjs:get(newObjs:size() - 1)
                placedObj:transmitCompleteItemToClients()
            end
        end

        square:RecalcAllWithNeighbours(true)
    end
end

Events.OnClientCommand.Add(BrushToolFixServer.onClientCommand)
