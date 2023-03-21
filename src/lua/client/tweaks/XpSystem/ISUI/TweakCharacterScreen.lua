--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

TweakCharacterScreen = {
    Original = {
        render = ISCharacterScreen.render
    }
}

-- render overrides the original ISCharacterScreen:render() function.
-- Adds characters coordinates.
TweakCharacterScreen.render = function(self)
    TweakCharacterScreen.Original.render(self)

    local smallFontHgt = getTextManager():getFontFromEnum(UIFont.Small):getLineHeight()

    local textWid1 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_char_Favourite_Weapon"))
    local textWid2 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_char_Zombies_Killed"))
    local textWid3 = getTextManager():MeasureStringX(UIFont.Small, getText("IGUI_char_Survived_For"))

    local x = 20 + math.max(textWid1, math.max(textWid2, textWid3))
    local z = self.height - smallFontHgt - 10

    if SandboxVars.ServerTweaker.DisplayCharacterCoordinates then
        local clock = UIManager.getClock()

        if instanceof(self.char, 'IsoPlayer') and clock and clock:isDateVisible() then
            z = z + smallFontHgt + 6;
            self:drawRect(30, z, self.width - 60, 1, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
            z = z + 6;

            self:drawTextRight("Coordinates", x, z, 1,1,1,1, UIFont.Small);
            self:drawText(string.format("%04d,%04d,%01d",self.char:getX(),self.char:getY(),self.char:getZ()), x + 10, z, 1,1,1,0.5, UIFont.Small);
        end
    end

    z = z + smallFontHgt + 10

    self:setHeightAndParentHeight(z)
end

ISCharacterScreen.render = TweakCharacterScreen.render;
