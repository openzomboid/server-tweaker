ColorInfo = {
    r = 1.0,
    g = 1.0,
    b = 1.0,
    a = 1.0,
}

ColorInfo.new = function(r, g, b, a)
    ColorInfo.r = r
    ColorInfo.g = g
    ColorInfo.b = b
    ColorInfo.a = a

    return ColorInfo
end

ColorInfo.getR = function() return ColorInfo.r end
ColorInfo.getG = function() return ColorInfo.g end
ColorInfo.getB = function() return ColorInfo.b end
