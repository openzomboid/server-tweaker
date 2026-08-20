--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

require "clientutils/ClientOptions/ClientOptions"
require "clientutils/SafehousesCache/SafehousesCache"

-- HighlightSafehouse is a container table for the safehouse visual highlights,
-- defining the default color and caching mechanism.
HighlightSafehouse = {
    -- Instantiate a new color vector using absolute RGBA components (Red, Green, Blue, Alpha)
    FLOOR_HIGHLIGHT_COLOR_GREEN = ColorInfo.new(0, 1, 0, 1.0), -- bright green highlight
    FLOOR_HIGHLIGHT_COLOR_RED = ColorInfo.new(1, 0, 0, 1.0), -- bright red highlight

    -- Set the max rendering/view distance for highlighting (PZ internal engine max grid view is around 60-70 tiles)
    MaxViewDistance = 70,

    SafehousesCache = nil
}

-- IsEnabledOnServer checks if this feature is allowed by the server's
-- current Sandbox settings.
function HighlightSafehouse.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.HighlightSafehouse
end

function HighlightSafehouse.IsGrandPermittedUser(character)
    return getPlayer():getRole() and getPlayer():getRole():hasCapability(Capability.CanGoInsideSafehouses)
end

-- OnOptionChange invoked by the game UI whenever the player toggles the
-- highlight option checkbox.
function HighlightSafehouse.OnOptionChange(self, option, enabled)
    ClientOptions.SetSelected("highlight_safehouse", enabled)
end

-- HighlightForUser highlights all safehouses where the player is a registered member.
-- It fetches the permitted zones from the local cache and visually highlights their floor tiles in green.
function HighlightSafehouse.HighlightForUser(character)
    -- Abort rendering passes if the spatial database cache was not initialized
    if not HighlightSafehouse.SafehousesCache then
        return
    end

    if character:getZ() < 0 then
        return
    end

    local safehouses = HighlightSafehouse.SafehousesCache.GetSafehouses()
    if not safehouses then
        return
    end

    local cell = getCell()

    for _, safehouse in pairs(safehouses) do
        local x1 = safehouse:getX()
        local x2 = safehouse:getX() + safehouse:getW() - 1
        local y1 = safehouse:getY()
        local y2 = safehouse:getY() + safehouse:getH() - 1

        -- Check if the safehouse is within the general field of view radius before scanning squares
        if IsoUtils.DistanceTo(character:getX(), character:getY(), safehouse:getX(), safehouse:getY()) <= HighlightSafehouse.MaxViewDistance then
            for x = x1, x2 do
                for y = y1, y2 do
                    local sq = cell:getGridSquare(x, y, 0)
                    if sq and sq:getFloor() then
                        local obj = sq:getFloor()
                        obj:setHighlighted(true)
                        obj:setHighlightColor(HighlightSafehouse.FLOOR_HIGHLIGHT_COLOR_GREEN)
                    end
                end
            end
        end
    end
end

-- HighlightForAdmin highlights absolutely all safehouses on the server for administrative overview.
-- It checks if the character has master permissions and highlights every safehouse floor tile on the map in red.
function HighlightSafehouse.HighlightForAdmin(character)
    if not HighlightSafehouse.IsGrandPermittedUser(character) then
        return
    end

    if character:getZ() < 0 then
        return
    end

    local cell = getCell()

    local safehouseList = SafeHouse.getSafehouseList()
    for i = 1, safehouseList:size() do
        local safehouse = safehouseList:get(i - 1)

        if safehouse then
            local x1 = safehouse:getX()
            local x2 = safehouse:getX() + safehouse:getW() - 1
            local y1 = safehouse:getY()
            local y2 = safehouse:getY() + safehouse:getH() - 1

            -- Check if the safehouse is within the general field of view radius before scanning squares
            if IsoUtils.DistanceTo(character:getX(), character:getY(), safehouse:getX(), safehouse:getY()) <= HighlightSafehouse.MaxViewDistance then
                for x = x1, x2 do
                    for y = y1, y2 do
                        local sq = cell:getGridSquare(x, y, 0)
                        if sq and sq:getFloor() then
                            local obj = sq:getFloor()
                            obj:setHighlighted(true)
                            obj:setHighlightColor(HighlightSafehouse.FLOOR_HIGHLIGHT_COLOR_RED)
                        end
                    end
                end
            end
        end
    end
end

-- OnGameStart injects the new setting into the client's options menu when the
-- world finishes loading.
function HighlightSafehouse.OnGameStart()
    if HighlightSafehouse.IsEnabledOnServer() then
        -- Instantiate the data container responsible for tracking safehouse zones within the streamable world
        HighlightSafehouse.SafehousesCache = SafehousesCache:new()

        local name = "highlight_safehouse"
        local selected = true -- The visual indicator defaults to "ON" for players
        local translation = getText("IGUI_UserPanel_HighlightSafehouse")

        -- Register the checkbox under the custom options system with its bound visibility and state callbacks
        ClientOptions.AddOption(name, selected, translation, HighlightSafehouse.IsEnabledOnServer, HighlightSafehouse.OnOptionChange)
    end
end

-- OnRenderTick process and draw visual bounds on every single frame tick.
function HighlightSafehouse.OnRenderTick(ticks)
    local character = getPlayer()
    if not character then
        return
    end

    if not HighlightSafehouse.IsEnabledOnServer() then
        return
    end

    local option = ClientOptions.GetOption("highlight_safehouse") or {}
    if not option.selected then
        return
    end

    if HighlightSafehouse.IsGrandPermittedUser(character) then
        HighlightSafehouse.HighlightForAdmin(character)
    end

    HighlightSafehouse.HighlightForUser(character)
end

Events.OnGameStart.Add(HighlightSafehouse.OnGameStart)
Events.OnRenderTick.Add(HighlightSafehouse.OnRenderTick)
