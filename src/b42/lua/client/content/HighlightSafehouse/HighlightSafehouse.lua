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
    FLOOR_HIGHLIGHT_COLOR = ColorInfo.new(0, 1, 0, 1.0), -- bright green highlight
    SafehousesCache = nil
}

-- IsEnabledOnTheServer checks if this feature is allowed by the server's
-- current Sandbox settings.
function HighlightSafehouse.IsEnabledOnTheServer()
    return SandboxVars.ServerTweaker.HighlightSafehouse
end

-- OnOptionChange invoked by the game UI whenever the player toggles the
-- highlight option checkbox.
function HighlightSafehouse.OnOptionChange(self, option, enabled)
    ClientOptions.SetSelected("highlight_safehouse", enabled)
end

-- OnGameStart injects the new setting into the client's options menu when the
-- world finishes loading.
function HighlightSafehouse.OnGameStart()
    if HighlightSafehouse.IsEnabledOnTheServer() then
        -- Instantiate the data container responsible for tracking safehouse zones within the streamable world
        HighlightSafehouse.SafehousesCache = SafehousesCache:new()

        local name = "highlight_safehouse"
        local selected = true -- The visual indicator defaults to "ON" for players
        local translation = getText("IGUI_UserPanel_HighlightSafehouse")

        -- Register the checkbox under the custom options system with its bound visibility and state callbacks
        ClientOptions.AddOption(name, selected, translation, HighlightSafehouse.IsEnabledOnTheServer, HighlightSafehouse.OnOptionChange)
    end
end

-- OnRenderTick process and draw visual bounds on every single frame tick.
function HighlightSafehouse.OnRenderTick(ticks)
    local character = getPlayer()
    if not character then
        return
    end

    if not HighlightSafehouse.IsEnabledOnTheServer() then
        return
    end

    local option = ClientOptions.GetOption("highlight_safehouse") or {}
    if not option.selected then
        return
    end

    -- Guard clause: abort rendering passes if the spatial database cache was not initialized
    if not HighlightSafehouse.SafehousesCache then
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

        for x = x1, x2 do
            for y = y1, y2 do
                local sq = cell:getGridSquare(x, y, 0)
                if sq and sq:getFloor() then
                    local obj = sq:getFloor()
                    obj:setHighlighted(true)
                    obj:setHighlightColor(HighlightSafehouse.FLOOR_HIGHLIGHT_COLOR)
                end
            end
        end
    end
end

Events.OnGameStart.Add(HighlightSafehouse.OnGameStart)
Events.OnRenderTick.Add(HighlightSafehouse.OnRenderTick)
