--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakDestroyStuffAction = {
    Original = {
        isValid = ISDestroyStuffAction.isValid
    },
    Textures = {
        South = {
            ["carpentry_02_101"] = true,             -- WoodenWallFrame
            ["walls_exterior_wooden_01_45"] = true,  -- WoodenWallLvl1
            ["walls_exterior_wooden_01_41"] = true,  -- WoodenWallLvl2
            ["walls_exterior_wooden_01_25"] = true,  -- WoodenWallLvl3
            ["walls_exterior_wooden_01_53"] = true,  -- WoodenWindowLvl1
            ["walls_exterior_wooden_01_49"] = true,  -- WoodenWindowLvl2
            ["walls_exterior_wooden_01_33"] = true,  -- WoodenWindowLvl3
            ["constructedobjects_01_69"] = true,     -- MetalFrame
            ["constructedobjects_01_65"] = true,     -- MetalWallLvl1
            ["constructedobjects_01_49"] = true,     -- MetalWallLvl2
            ["constructedobjects_01_73"] = true,     -- MetalWindowLvl1
            ["constructedobjects_01_57"] = true,     -- MetalWindowLvl2
            ["carpentry_02_41"] = true,              -- WoodenFence
            ["constructedobjects_01_81"] = true,     -- Metal Panel Fence
            ["constructedobjects_01_61"] = true,     -- Pole Fence (Metal)
            ["fencing_01_57"] = true,                -- Big Metal Wire Fence
            ["constructedobjects_01_77"] = true,     -- Big Metal Pole Fence
            ["fixtures_doors_fences_01_98"] = true,  -- Wooden Double Door
            ["fixtures_doors_fences_01_107"] = true, -- Wooden Double Door
        },
        East = {
            ["carpentry_02_100"] = true,             -- WoodenWallFrame
            ["walls_exterior_wooden_01_44"] = true,  -- WoodenWallLvl1
            ["walls_exterior_wooden_01_40"] = true,  -- WoodenWallLvl2
            ["walls_exterior_wooden_01_24"] = true,  -- WoodenWallLvl3
            ["walls_exterior_wooden_01_52"] = true,  -- WoodenWindowLvl1
            ["walls_exterior_wooden_01_48"] = true,  -- WoodenWindowLvl2
            ["walls_exterior_wooden_01_32"] = true,  -- WoodenWindowLvl3
            ["constructedobjects_01_68"] = true,     -- MetalFrame
            ["constructedobjects_01_64"] = true,     -- MetalWallLvl1
            ["constructedobjects_01_48"] = true,     -- MetalWallLvl2
            ["constructedobjects_01_72"] = true,     -- MetalWindowLvl1
            ["constructedobjects_01_56"] = true,     -- MetalWindowLvl2
            ["carpentry_02_40"] = true,              -- WoodenFence
            ["constructedobjects_01_82"] = true,     -- Metal Panel Fence
            ["constructedobjects_01_62"] = true,     -- Pole Fence (Metal)
            ["fencing_01_58"] = true,                -- Big Metal Wire Fence
            ["constructedobjects_01_78"] = true,     -- Big Metal Pole Fence
            --["fixtures_doors_fences_01_98"] = true,  -- Wooden Double Door
            ["fixtures_doors_fences_01_105"] = true, -- Wooden Double Door
        },
    }
}

function TweakDestroyStuffAction.isValid(self)
    local valid = TweakDestroyStuffAction.Original.isValid(self)
    if not valid then
        return valid
    end

    if ISBuildMenu.cheat then
        return true
    end

    local x = self.item:getSquare():getX()
    local y = self.item:getSquare():getY()

    local texture = self.item:getTextureName()

    local safehouse = openutils.GetSafehouseByXY(x, y)
    if safehouse and not openutils.IsPlayerMemmberOfSafehouse(self.character, safehouse) then
        if openutils.IsInSafehouseSouthEastExtraTile(safehouse, x, y) then
            return true
        end

        if openutils.IsInSafehouseSouthExtraLine(safehouse, x, y) then
            if instanceof(self.item, 'IsoThumpable') then
                if self.item:getNorth() == true and not self.item:isBlockAllTheSquare() then
                    return false
                end
            else
                if TweakDestroyStuffAction.Textures.South[texture] == true then
                    return false
                end
            end

            return true
        end

        if openutils.IsInSafehouseEastExtraLine(safehouse, x, y) then
            if instanceof(self.item, 'IsoThumpable') then
                if self.item:getNorth() == false and not self.item:isBlockAllTheSquare() then
                    return false
                end
            else
                if TweakDestroyStuffAction.Textures.East[texture] == true then
                    return false
                end
            end

            return true
        end

        return false
    end

    return true
end

ISDestroyStuffAction.isValid = TweakDestroyStuffAction.isValid;
