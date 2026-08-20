--
-- Copyright (c) 2026 outdead and James "J" Kelly.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

local lastPlacedTime = 0

BrushToolFix = {
    RateLimitMs = 150,
    OriginalFunctions = {
        ISBrushToolTileCursor_create = nil -- ISBrushToolTileCursor.create is not exist on this time
    }
}

-- IsEnabledOnServer checks if the brush tool anti-spam fix is active on the server.
-- It queries the global sandbox variable configuration to determine if rate limiting
-- should be enforced.
function BrushToolFix.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.BrushToolFix
end

-- ISBrushToolTileCursor_create handles the client-side placement logic for the admin brush tool.
-- It enforces a milliseconds-based placement cooldown, validates that the requested sprite does
-- not already exist on the target coordinate, and offloads the creation to the server via network
-- commands.
function BrushToolFix.ISBrushToolTileCursor_create(self, x, y, z, north, sprite)
    if not BrushToolFix.IsEnabledOnServer() then
        BrushToolFix.OriginalFunctions.ISBrushToolTileCursor_create(self, x, y, z, north, sprite)
        return
    end

    local currentTime = getTimestampMs()
    if currentTime - lastPlacedTime < BrushToolFix.RateLimitMs then
        logger.Debug("BrushToolFix: rate limit")

        return
    end
    lastPlacedTime = currentTime

    local square = getCell():getGridSquare(x, y, z)
    local objs = square:getObjects()

    local tileAlreadyOnSquare = false
    for i=0, objs:size() - 1 do
        if objs:get(i):getSprite() ~= nil and objs:get(i):getSprite():getName() == sprite then
            tileAlreadyOnSquare = true
        end
    end

    if tileAlreadyOnSquare then
        logger.Debug("BrushToolFix: tile already on square")

        return
    end

    local isNorth = north
    if isNorth == nil and self.north ~= nil then
        isNorth = self.north
    end

    local args = {
        x = x,
        y = y,
        z = z,
        sprite = sprite,
        north = isNorth or false
    }

    sendClientCommand(self.character, "ServerTweaker", "BrushToolFix_create", args)
end

-- BrushToolFix.OnGameStart initializes the hook mechanism for the brush tool once the
-- game context is ready.
-- It safely captures the vanilla ISBrushToolTileCursor.create method and hot-swaps it
-- with the rate-limited version.
function BrushToolFix.OnGameStart()
    if not ISBrushToolTileCursor then
        return
    end

    BrushToolFix.OriginalFunctions.ISBrushToolTileCursor_create = ISBrushToolTileCursor.create
    ISBrushToolTileCursor.create = BrushToolFix.ISBrushToolTileCursor_create
end

Events.OnGameStart.Add(BrushToolFix.OnGameStart)
