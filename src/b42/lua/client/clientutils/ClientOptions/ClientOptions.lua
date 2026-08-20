--
-- Copyright (c) 2026 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

--- =========================================================================================================
--- PUBLIC MODULE: ClientOptions
--- =========================================================================================================

--- ClientOptions module acts as a global shared registry system, providing a clean public interface for
--- third-party mod modules to inject customizable client toggles that seamlessly sync to an independent
--- configuration file on disk.
ClientOptions = {
    Options = {},
    Storage = nil,
    OriginalFunctions = {
        ISUserPanelUI_create = ISUserPanelUI.create
    }
}

--- AddOption registers a new configurable tick box to the user panel, binds setting
--- change callbacks, and resolves local persistence data state.
---
--- @param name string - Unique configuration tracking key identifying this particular option profile layout (e.g. "highlight_safehouse").
--- @param selected boolean - Fallback configuration default visibility flag if a persistent state storage record has not yet materialized.
--- @param translation string - Pre-localized translation string text node to bind as the checkbox graphical UI text label descriptor.
--- @param IsEnabledOnServer function - Functional evaluator callback used to confirm current multiplayer/sandbox server validation policies.
--- @param onOptionChange function - Executable callback fired whenever a player clicks the checkbox element to toggle state values.
---
--- @example How to consume this method from an external module (e.g. HighlightSafehouse):
---     ClientOptions.AddOption(
---         "highlight_safehouse",
---         true,
---         getText("IGUI_UserPanel_HighlightSafehouse"),
---         HighlightSafehouseIsEnabledOnServer,
---         HighlightSafehouse.OnOptionChange
---     )
function ClientOptions.AddOption(name, selected, translation, isEnabledOnServer, onOptionChange)
    local option = {
        name = name,
        selected = selected,
        translation = translation,
        isEnabledOnServer = isEnabledOnServer,
        onOptionChange = onOptionChange
    }

    if type(option.isEnabledOnServer) ~= 'function' or type(option.onOptionChange) ~= 'function' then
        logger.Debug("ClientOptions: Option is invalid and was skipped", option)
        
        return
    end

    -- Lazy Loading: Initialize the physical file structure node under Zomboid/Lua/client-options.ini
    -- ONLY upon the first registration request
    if ClientOptions.Storage == nil then
        ClientOptions.Storage = OptionsStorage:new("client-options", {})
    end

    -- Serialization layer: Determine if an operational config value already exists saved down within disk spaces
    if ClientOptions.Storage.Get(name) == nil then
        ClientOptions.Storage.SetBool(name, selected)
        logger.Debug("ClientOptions.AddOption: " .. name .. ": inserted to file with value: " .. tostring(option.selected))
    else
        -- Recovery loop: Update memory tracking parameters dynamically based on data values returned from file buffer cache
        option.selected = ClientOptions.Storage.GetBool(name)
        logger.Debug("ClientOptions.AddOption: " .. name .. " got from file with value: " .. tostring(option.selected))
    end

    ClientOptions.Options[name] = option
end

--- SetSelected updates the memory runtime storage parameters dynamically and
--- updates configuration entries down inside local disk tracks.
---
--- @param name string - Unique configuration tracking key identifying this particular option profile layout
--- @param enabled boolean - The fresh updated targeted state value to force down to the current checkbox record
---
--- @example Update a tracking value manually following a state change trigger callback:
---     function HighlightSafehouse.OnOptionChange(self, option, enabled)
---         ClientOptions.SetSelected("highlight_safehouse", enabled)
---     end
function ClientOptions.SetSelected(name, enabled)
    if ClientOptions.Options[name] then
        ClientOptions.Options[name].selected = enabled

        if ClientOptions.Storage.SetBool then
            ClientOptions.Storage.SetBool(name, enabled)
        end
    end
end

--- GetOption getters specific setting attributes from memory profiles.
--- .
--- @param name string - Unique configuration tracking key identifying this particular option profile layout
--- @return table|nil - Returns the option configurations dataset dictionary or nil if not found
---
--- @example Fetch checking configuration status flags from frame tick render loops:
---     local option = ClientOptions.GetOption("highlight_safehouse") or {}
---     if not option.selected then return end
function ClientOptions.GetOption(name)
    return ClientOptions.Options[name]
end

--- ISUserPanelUI_create intercepts the native creation pipeline of ISUserPanelUI
--- to inject newly configured settings widgets dynamically.
---
--- @param self ISUserPanelUI Represents the physical instantiated user panel window container canvas instance context.
function ClientOptions.ISUserPanelUI_create(self)
    ClientOptions.OriginalFunctions.ISUserPanelUI_create(self)

    -- Dynamic positioning algebra: Determine baseline panel horizontal footprint lengths based on text measurements and margins
    local btnWid = UI_BORDER_SPACING*2+getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_UserPanel_ShowConnectionInfo")) + BUTTON_HGT
    local y = self.cancel.y

    for name, option in pairs(ClientOptions.Options) do
        if option.isEnabledOnServer() then
            self[option.name] = ISTickBox:new(self.factionBtn.x, y, btnWid, BUTTON_HGT, option.translation, self, option.onOptionChange)
            self[option.name]:initialise()
            self[option.name]:instantiate()
            self[option.name].selected[1] = option.selected
            self[option.name]:addOption(option.translation)
            self:addChild(self[option.name])
            y = y + BUTTON_HGT + UI_BORDER_SPACING

            -- Move the close buttons dynamically down the canvas grid layout to adjust cleanly beneath the new checkboxes
            if self.cancel and self.cancel.setY then
                self.cancel:setY(y)
            end

            -- Dynamic Dimension Normalization Loop: Scale sibling interface elements to share matching widths uniformly
            local width = 0
            for _,child in pairs(self:getChildren()) do
                width = math.max(width, child:getWidth())
            end
            for _,child in pairs(self:getChildren()) do
                child:setWidth(width)
            end

            -- Readjust parent UI pane tracking dimensions safely so nothing extends past structural boundary borders
            self:setWidth(UI_BORDER_SPACING*2 + 2 + btnWid)
            self:setHeight(self.cancel.y + BUTTON_HGT + UI_BORDER_SPACING + 1)
        end
    end
end

ISUserPanelUI.create = ClientOptions.ISUserPanelUI_create
