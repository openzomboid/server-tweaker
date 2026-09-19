--
-- Copyright (c) 2026 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local logger = ConsoleLogger.new()

StoreAdminPowers = {
    AdminOptions = nil,
    OriginalFunctions = {
        ISAdminPowerUI_addOptionLeft = ISAdminPowerUI.addOptionLeft,
        ISAdminPowerUI_addOptionRight = ISAdminPowerUI.addOptionRight
    }
}

function StoreAdminPowers.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.StoreAdminPowers
end

function StoreAdminPowers.SetAdminPower()
    if not StoreAdminPowers.IsEnabledOnServer() then
        return
    end

    local character = getPlayer()

    if StoreAdminPowers.AdminOptions == nil then
        StoreAdminPowers.AdminOptions = OptionsStorage:new("admin-powers", {})
    end

    if isClient() and character then
        logger.Debug("called StoreAdminPowers.SetAdminPower")

        for _, option in ipairs(ISAdminPowerUI.OptionList) do
            if character:getRole():hasCapability(option.capability) then
                logger.Debug("StoreAdminPowers.SetAdminPower: " .. option.id)
                local value = StoreAdminPowers.AdminOptions.GetBool(option.id)

                option:setValue(value)
            end
        end
    end
end

function StoreAdminPowers.ISAdminPowerUI_addOptionLeft(self, option)
    logger.Debug("StoreAdminPowers.addOptionLeft")

    StoreAdminPowers.OriginalFunctions.ISAdminPowerUI_addOptionLeft(self, option)

    if StoreAdminPowers.IsEnabledOnServer() then
        if self.player:getRole():hasCapability(option.capability) then
            if StoreAdminPowers.AdminOptions then
                local value = option:getValue()

                logger.Debug("StoreAdminPowers.addOption: set option id = " .. option.id .. " to value " .. tostring(value))

                StoreAdminPowers.AdminOptions.SetBool(option.id, value)
            else
                logger.Debug("StoreAdminPowers.addOption: no AdminOptions")
            end
        end
    end
end

function StoreAdminPowers.ISAdminPowerUI_addOptionRight(self, option)
    logger.Debug("StoreAdminPowers.addOptionRight")

    StoreAdminPowers.OriginalFunctions.ISAdminPowerUI_addOptionRight(self, option)

    if StoreAdminPowers.IsEnabledOnServer() then
        if self.player:getRole():hasCapability(option.capability) then
            if StoreAdminPowers.AdminOptions then
                local value = option:getValue()

                logger.Debug("StoreAdminPowers.addOption: set option id = " .. option.id .. " to value " .. tostring(value))

                StoreAdminPowers.AdminOptions.SetBool(option.id, value)
            else
                logger.Debug("StoreAdminPowers.addOption: no AdminOptions")
            end
        end
    end
end

-- OnCreatePlayer adds callback for player OnCreatePlayer event.
function StoreAdminPowers.OnCreatePlayer(id)
    if not StoreAdminPowers.IsEnabledOnServer() then
        return
    end

    local ticker = {}

    ticker.OnTick = function()
        local character = getPlayer()

        if character then
            Events.OnTick.Remove(ticker.OnTick)
            StoreAdminPowers.SetAdminPower()
        end
    end

    Events.OnTick.Add(ticker.OnTick)
end

Events.OnCreatePlayer.Add(StoreAdminPowers.OnCreatePlayer)

ISAdminPowerUI.addOptionLeft = StoreAdminPowers.ISAdminPowerUI_addOptionLeft
ISAdminPowerUI.addOptionRight = StoreAdminPowers.ISAdminPowerUI_addOptionRight
