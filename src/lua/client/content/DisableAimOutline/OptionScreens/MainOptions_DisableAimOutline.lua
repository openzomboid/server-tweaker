--
-- Copyright (c) 2022 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

MainOptions_DisableAimOutline = {
    Original = {
        create = MainOptions.create
    }
}

-- create overrides the original MainOptions:create function.
-- Forces turns off client option "AimOutline".
MainOptions_DisableAimOutline.create = function(self)
    MainOptions_DisableAimOutline.Original.create(self)

    if not SandboxVars.ServerTweaker.DisableAimOutline then
        return
    end

    for optID, gameOption in pairs(self.gameOptions.options) do
        if gameOption.name == "aimOutline" and SandboxVars.ServerTweaker.DisableAimOutline then
            gameOption.control.options[2] = nil
            gameOption.control.options[3] = nil
        end
    end
end

MainOptions.create = MainOptions_DisableAimOutline.create;
