--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

DisableAimOutline = {}

-- OnGameStart adds callback for OnGameStart global event.
function DisableAimOutline.OnGameStart()
    if SandboxVars.ServerTweaker.DisableAimOutline then
        getCore():setOptionAimOutline(1);
    end
end

Events.OnGameStart.Add(DisableAimOutline.OnGameStart);
