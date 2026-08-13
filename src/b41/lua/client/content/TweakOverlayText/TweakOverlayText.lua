--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakOverlayText = {}

-- OnGameStart adds callback for OnGameStart global event.
function TweakOverlayText.OnGameStart()
    if SandboxVars.ServerTweaker.TweakOverlayText then
        setShowConnectionInfo(true);
        setShowServerInfo(false);
    end
end

Events.OnGameStart.Add(TweakOverlayText.OnGameStart);
