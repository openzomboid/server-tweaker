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

    logger.Debug("StoreAdminPowers: called SetAdminPower")

    local character = getPlayer()

    if isClient() and character then
        if StoreAdminPowers.AdminOptions == nil then
            logger.Debug("SetAdminPowers: init AdminOptions")

            StoreAdminPowers.AdminOptions = OptionsStorage:new("admin-powers", {})
        end

        for _, option in ipairs(ISAdminPowerUI.OptionList) do
            if isDebugEnabled() or character:getRole():hasCapability(option.capability) then
                if character:getRole():hasCapability(option.capability) then
                    logger.Debug("SetAdminPowers: user " .. character:getUsername() .. " has capability " .. option.id)
                else
                    logger.PrintOnce("debug", "SetAdminPowers: user " .. character:getUsername() .. " is in debug mode")
                end

                local value = StoreAdminPowers.AdminOptions.GetBool(option.id)

                option.player = character
                option:setValue(value)
            end
        end
    end
end

function StoreAdminPowers.doOption(option)
    if not StoreAdminPowers.IsEnabledOnServer() then
        return
    end

    local character = getPlayer()

    if not (isDebugEnabled() or character:getRole():hasCapability(option.capability)) then
        logger.Debug("doOption: general user, no need to apply admin options")
        return
    end

    if not StoreAdminPowers.AdminOptions then
        logger.Error("doOption: no AdminOptions")
        return
    end

    option.player = character

    local value = option:getValue()

    if StoreAdminPowers.AdminOptions.GetBool(option.id) ~= value then
        logger.Debug("doOption: set option " .. option.id .. " to value " .. tostring(value))
        StoreAdminPowers.AdminOptions.SetBool(option.id, value)
    else
        logger.Debug("doOption: option " .. option.id .. " was already stored")
    end
end

function StoreAdminPowers.ISAdminPowerUI_addOptionLeft(self, option)
    logger.Debug("StoreAdminPowers: called addOptionLeft")

    StoreAdminPowers.OriginalFunctions.ISAdminPowerUI_addOptionLeft(self, option)

    StoreAdminPowers.doOption(option)
end

function StoreAdminPowers.ISAdminPowerUI_addOptionRight(self, option)
    logger.Debug("StoreAdminPowers: called addOptionRight")

    StoreAdminPowers.OriginalFunctions.ISAdminPowerUI_addOptionRight(self, option)

    StoreAdminPowers.doOption(option)
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
