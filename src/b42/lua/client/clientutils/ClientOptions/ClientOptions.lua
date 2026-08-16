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

ClientOptions = {
    Options = {},
    Storage = nil,
    OriginalFunctions = {
        ISUserPanelUI_create = ISUserPanelUI.create
    }
}

function ClientOptions.AddOption(name, selected, translation, isEnabledOnTheServer, onOptionChange)
    local option = {
        name = name,
        selected = selected,
        translation = translation,
        isEnabledOnTheServer = isEnabledOnTheServer,
        onOptionChange = onOptionChange
    }

    if type(option.isEnabledOnTheServer) ~= 'function' or type(option.onOptionChange) ~= 'function' then
        logger.Debug("ClientOptions: Option is invalid and was skipped", option)
        
        return
    end

    if ClientOptions.Storage == nil then
        ClientOptions.Storage = OpenOptions:new("client-options", {})
    end

    if ClientOptions.Storage.Get(name) == nil then
        ClientOptions.Storage.SetBool(name, enabled)

        logger.Debug("ClientOptions.AddOption: " .. name .. ": insert to file")
    else
        option.selected = ClientOptions.Storage.GetBool(name)

        logger.Debug("ClientOptions.AddOption: " .. name .. " get from file with value: " .. tostring(option.selected))
    end

    ClientOptions.Options[name] = option
end

function ClientOptions.SetSelected(name, enabled)
    if ClientOptions.Options[name] then
        ClientOptions.Options[name].selected = enabled

        if ClientOptions.Storage.SetBool then
            ClientOptions.Storage.SetBool(name, enabled)
        end
    end
end

function ClientOptions.GetOption(name)
    return ClientOptions.Options[name]
end

function ClientOptions.ISUserPanelUI_create(self)
    ClientOptions.OriginalFunctions.ISUserPanelUI_create(self)

    local btnWid = UI_BORDER_SPACING*2+getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_UserPanel_ShowConnectionInfo")) + BUTTON_HGT
    local y = self.cancel.y

    for name, option in pairs(ClientOptions.Options) do
        if option.isEnabledOnTheServer() then
            self[option.name] = ISTickBox:new(self.factionBtn.x, y, btnWid, BUTTON_HGT, option.translation, self, option.onOptionChange)
            self[option.name]:initialise()
            self[option.name]:instantiate()
            self[option.name].selected[1] = option.selected
            self[option.name]:addOption(option.translation)
            self:addChild(self[option.name])
            y = y + BUTTON_HGT + UI_BORDER_SPACING

            if self.cancel and self.cancel.setY then
                self.cancel:setY(y)
            end

            local width = 0
            for _,child in pairs(self:getChildren()) do
                width = math.max(width, child:getWidth())
            end
            for _,child in pairs(self:getChildren()) do
                child:setWidth(width)
            end

            self:setWidth(UI_BORDER_SPACING*2 + 2 + btnWid)
            self:setHeight(self.cancel.y + BUTTON_HGT + UI_BORDER_SPACING + 1)
        end
    end
end

ISUserPanelUI.create = ClientOptions.ISUserPanelUI_create
