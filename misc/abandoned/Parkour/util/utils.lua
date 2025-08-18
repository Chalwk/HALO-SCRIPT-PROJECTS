local util = {}

local sqrt, pow = math.sqrt, math.pow

function util:calculateDistance(x1, y1, z1, x2, y2, z2)
    return sqrt(pow(x2- x1, 2) + pow(y2 - y1,2) + pow(z2 - z1,2))
end

return util