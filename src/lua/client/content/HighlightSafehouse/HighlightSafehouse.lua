--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local FLOOR_HIGHLIGHT_COLOR = ColorInfo.new(0, 1, 0, 1.0);

HighlightSafehouse = {}

-- ticks adds ticker for highlight players safehouses.
HighlightSafehouse.OnRenderTick = function(ticks)
    local character = getPlayer()
    if not character then
        return
    end

    if not SandboxVars.ServerTweaker.HighlightSafehouse then
        return
    end

    if ClientTweaker.Options.GetBool("highlight_safehouse") == false then
        return
    end

    if not ClientTweaker.Cache then
        return
    end

    local safehouses = ClientTweaker.Cache.GetSafehouses()

    if safehouses then
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
                        obj:setHighlightColor(FLOOR_HIGHLIGHT_COLOR);
                    end
                end
            end
        end
    end
end

Events.OnRenderTick.Add(HighlightSafehouse.OnRenderTick);
