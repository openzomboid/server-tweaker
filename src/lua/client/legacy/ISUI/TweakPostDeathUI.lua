--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakPostDeathUI = {
    Original = {},
    IsDead = false
}

-- OnPlayerDeath blackouts the screen upon death.
TweakPostDeathUI.OnPlayerDeath = function(playerObj)
    if not SandboxVars.ServerTweaker.ScreenBlackoutOnDeath then
        return
    end

    TweakPostDeathUI.IsDead = true

    local playerNum = playerObj:getPlayerNum()

    UIManager.setFadeBeforeUI(playerNum, true)
    UIManager.FadeOut(playerNum, 1)
end

-- OnCreatePlayer adds callback for player OnCreatePlayerData event.
TweakPostDeathUI.OnCreatePlayer = function(id)
    if not TweakPostDeathUI.IsDead then
        return
    end

    local ticker = {}

    ticker.OnTick = function()
        local player = getPlayer()
        if player then
            TweakPostDeathUI.IsDead = false
            UIManager.FadeIn(player:getPlayerNum(), 0);
            Events.OnTick.Remove(ticker.OnTick);
        end
    end

    Events.OnTick.Add(ticker.OnTick);
end

Events.OnPlayerDeath.Add(TweakPostDeathUI.OnPlayerDeath)
Events.OnCreatePlayer.Add(TweakPostDeathUI.OnCreatePlayer)
