--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

require "clientutils/ClientOptions/ClientOptions"
require "clientutils/SafehousesCache/SafehousesCache"

local logger = ConsoleLogger.new()

HighlightSafehouse = {
    FLOOR_HIGHLIGHT_COLOR = ColorInfo.new(0, 1, 0, 1.0), -- green
    SafehousesCache = nil
}

function HighlightSafehouse.IsEnabledOnTheServer()
    return SandboxVars.ServerTweaker.HighlightSafehouse
end

function HighlightSafehouse.OnOptionChange(self, option, enabled)
    ClientOptions.SetSelected("highlight_safehouse", enabled)
end

function HighlightSafehouse.OnGameStart()
    if HighlightSafehouse.IsEnabledOnTheServer() then
        HighlightSafehouse.SafehousesCache = SafehousesCache:new()

        local name = "highlight_safehouse"
        local selected = true -- default value
        local translation = getText("IGUI_UserPanel_HighlightSafehouse")

        ClientOptions.AddOption(name, selected, translation, HighlightSafehouse.IsEnabledOnTheServer, HighlightSafehouse.OnOptionChange)
    end
end

-- ticks adds ticker for highlight players safehouses.
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
