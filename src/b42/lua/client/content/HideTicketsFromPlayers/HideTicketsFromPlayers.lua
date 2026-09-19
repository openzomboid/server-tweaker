--
-- Copyright (c) 2026 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

HideTicketsFromPlayers = {
    OriginalFunctions = {
        ISUserPanelUI_create = ISUserPanelUI.create
    }
}

function HideTicketsFromPlayers.IsEnabledOnServer()
    return SandboxVars.ServerTweaker.HideTickets
end

function HideTicketsFromPlayers.ISUserPanelUI_create(self)
    HideTicketsFromPlayers.OriginalFunctions.ISUserPanelUI_create(self)

    if not HideTicketsFromPlayers.IsEnabledOnServer() then
        return
    end

    ---- Disable server options button
    --if SandboxVars.ServerTweaker.HideServerOptionsFromPlayers then
    --    self.serverOptionBtn.enable = false
    --end

    -- Disable tickets button
    self.ticketsBtn.enable = false
end

ISUserPanelUI.create = HideTicketsFromPlayers.ISUserPanelUI_create
