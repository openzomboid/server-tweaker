--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakMapSpawnSelect = {
    Original = {
        getSpawnRegions = MapSpawnSelect.getSpawnRegions,
        fillList = MapSpawnSelect.fillList,
    }
}

-- getSpawnRegions rewrites original MapSpawnSelect.getSpawnRegions function.
-- Adds Safehouse to spawn locations.
TweakMapSpawnSelect.getSpawnRegions = function(self)
    if not SandboxVars.ServerTweaker.AddSafehouseToSpawnLocations then
        TweakMapSpawnSelect.Original.getSpawnRegions(self)
        return
    end

    local regions = self:getFixedSpawnRegion() or self:getChallengeSpawnRegion()
    if regions then
        return regions
    end

    regions = self:getSafehouseSpawnRegion() or {}
    local spawnRegions = SpawnRegionMgr.getSpawnRegions()

    for _, v in ipairs(spawnRegions) do
        table.insert(regions, v)
    end

    return regions
end

-- fillList rewrites original MapSpawnSelect.fillList function.
-- Sets Safehouse as first spawn location.
TweakMapSpawnSelect.fillList = function(self)
    if not SandboxVars.ServerTweaker.AddSafehouseToSpawnLocations then
        TweakMapSpawnSelect.Original.fillList(self)
        return
    end

    self.listbox:clear()
    local regions = self:getSpawnRegions()
    if not regions then return end

    local safehouseItem

    for _, v in ipairs(regions) do
        local info = getMapInfo(v.name)
        if info then
            local item = {};
            item.name = info.title or "NO TITLE";
            item.region = v;
            item.dir = v.name;
            item.desc = info.description or "NO DESCRIPTION";
            item.worldimage = info.thumb;
            self.listbox:addItem(item.name, item);
        else
            local item = {}
            item.name = v.name;
            item.region = v;
            item.dir = "";
            item.desc = "";
            item.worldimage = nil;

            if v.name == getText("UI_mapspawn_Safehouse") and SandboxVars.ServerTweaker.AddSafehouseToSpawnLocations then
                safehouseItem = item
                safehouseItem.desc = getText("UI_mapspawn_SafehouseDescription")
            else
                self.listbox:addItem(item.name, item);
            end

        end
    end

    self.listbox:sort()

    if safehouseItem then
        self.listbox:insertItem(1, safehouseItem.name, safehouseItem);
    end

    self:hideOrShowSaveName()
end

MapSpawnSelect.getSpawnRegions = TweakMapSpawnSelect.getSpawnRegions;
MapSpawnSelect.fillList = TweakMapSpawnSelect.fillList;
