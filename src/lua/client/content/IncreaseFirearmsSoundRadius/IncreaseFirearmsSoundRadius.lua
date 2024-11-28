--
-- Copyright (c) 2024 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

local IncreaseFirearmsSoundRadius = {}

-- TweakFirearmsSoundRadius returns SoundRadius to 41.56 values for firearms
-- if enabled.
function IncreaseFirearmsSoundRadius.TweakFirearmsSoundRadius()
    if not SandboxVars.ServerTweaker.TweakFirearmsSoundRadius then
        return
    end

    local tweaker = OpenItemTweaker:new()

    tweaker.Add("Base.Pistol3", "SoundRadius", "100");
    tweaker.Add("Base.Pistol2", "SoundRadius", "70");
    tweaker.Add("Base.Revolver_Short", "SoundRadius", "30");
    tweaker.Add("Base.Revolver", "SoundRadius", "70");
    tweaker.Add("Base.Pistol", "SoundRadius", "50");
    tweaker.Add("Base.Revolver_Long", "SoundRadius", "120");

    tweaker.Add("Base.DoubleBarrelShotgun", "SoundRadius", "200");
    tweaker.Add("Base.DoubleBarrelShotgunSawnoff", "SoundRadius", "250");
    tweaker.Add("Base.Shotgun", "SoundRadius", "200");
    tweaker.Add("Base.ShotgunSawnoff", "SoundRadius", "250");

    tweaker.Add("Base.AssaultRifle2", "SoundRadius", "90");
    tweaker.Add("Base.AssaultRifle", "SoundRadius", "100");
    tweaker.Add("Base.VarmintRifle", "SoundRadius", "150");
    tweaker.Add("Base.HuntingRifle", "SoundRadius", "150");
end

IncreaseFirearmsSoundRadius.TweakFirearmsSoundRadius();
