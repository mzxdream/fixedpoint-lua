local FixedMath = {}

FixedMath.SQRT2      = FixedNumber.FromRaw(FixedConsts.SQRT2)
FixedMath.HALF_SQRT2 = FixedNumber.FromRaw(FixedConsts.HALF_SQRT2)
FixedMath.PI         = FixedNumber.FromRaw(FixedConsts.PI)
FixedMath.HALF_PI    = FixedNumber.FromRaw(FixedConsts.HALF_PI)
FixedMath.TWO_PI     = FixedNumber.FromRaw(FixedConsts.TWO_PI)

FixedMath.Clamp = function(a, mina, maxa)
    if a < mina then
        return mina:Clone()
    elseif a > maxa then
        return maxa:Clone()
    else
        return a:Clone()
    end
end

FixedMath.Pow = function(a, n)
    if n == 0 then
        return FixedNumber.ONE:Clone()
    elseif n == 1 or a == FixedNumber.ZERO or a == FixedNumber.ONE then
        return a:Clone()
    elseif n < 0 then
        return FixedMath.Pow(FixedNumber.ONE / a, -n)
    elseif (n & 1) == 0 then
        return FixedMath.Pow(a * a, n >> 1)
    else
        return FixedMath.Pow(a * a, n >> 1) * a
    end
end

FixedMath.Min = function(a, b)
    if a < b then
        return a:Clone()
    else
        return b:Clone()
    end
end

FixedMath.Max = function(a, b)
    if a < b then
        return b:Clone()
    else
        return a:Clone()
    end
end

FixedMath.Abs = function(a)
    if a < FixedNumber.ZERO then
        return -a
    else
        return a:Clone()
    end
end

FixedMath.Sqrt = function(a)
    if a <= FixedNumber.ZERO then
        return FixedNumber.ZERO:Clone()
    elseif a == FixedNumber.ONE then
        return FixedNumber.ONE:Clone()
    end
    local x = a / FixedNumber.TWO
    while true do
        local y = x
        x = (x + a / x) / FixedNumber.TWO
        if FixedMath.Abs(x - y) <= FixedNumber.EPS then
            break
        end
    end
    return x
end

FixedMath.Rad2Deg = function(a)
    local val = a:Get()
    if val < 0 then
        val = -val
        for i = #FixedConsts.PI_TABLE, 2, -1 do
            if val > FixedConsts.PI_TABLE[i] then
                val = val - FixedConsts.PI_TABLE[i]
            end
        end
        if val > 0 then
            val = FixedConsts.TWO_PI - val
        end
    else
        for i = #FixedConsts.PI_TABLE, 2, -1 do
            if val > FixedConsts.PI_TABLE[i] then
                val = val - FixedConsts.PI_TABLE[i]
            end
        end
    end
    return FixedNumber.FromRaw(val * 360 * FixedNumber.FRACTIONAL_BASE // FixedConsts.TWO_PI)
end

FixedMath.Deg2Rad = function(a)
    local val = a:Get() % (360 * FixedNumber.FRACTIONAL_BASE)
    if val < 0 then
        val = val + 360 * FixedNumber.FRACTIONAL_BASE
    end
    return FixedNumber.FromRaw(val * FixedConsts.TWO_PI // (360 * FixedNumber.FRACTIONAL_BASE))
end

--[0-90)
local function CosDegLookupTable(deg)
    return FixedConsts.COS_TABLE[deg * #FixedConsts.COS_TABLE // (90 * FixedNumber.FRACTIONAL_BASE) + 1]
end

local function CosDegRaw(val)
    if val < 0 then
        val = -val
    end
    val = val % (360 * FixedNumber.FRACTIONAL_BASE)
    if val < 90 * FixedNumber.FRACTIONAL_BASE then
        return CosDegLookupTable(val)
    elseif val < 180 * FixedNumber.FRACTIONAL_BASE then
        return -CosDegLookupTable(180 * FixedNumber.FRACTIONAL_BASE - val)
    elseif val < 270 * FixedNumber.FRACTIONAL_BASE then
        return -CosDegLookupTable(val - 180 * FixedNumber.FRACTIONAL_BASE)
    else
        return CosDegLookupTable(360 * FixedNumber.FRACTIONAL_BASE - val)
    end
end

FixedMath.SinDeg = function(a)
    return FixedNumber.FromRaw(-CosDegRaw(a:Get() + 90 * FixedNumber.FRACTIONAL_BASE))
end

FixedMath.CosDeg = function(a)
    return FixedNumber.FromRaw(CosDegRaw(a:Get()))
end

FixedMath.TanDeg = function(a)
    return FixedMath.SinDeg(a) / FixedMath.CosDeg(a)
end

FixedMath.Sin = function(a)
    return FixedMath.SinDeg(FixedMath.Rad2Deg(a))
end

FixedMath.Cos = function(a)
    return FixedMath.CosDeg(FixedMath.Rad2Deg(a))
end

FixedMath.Asin = function(a)
    return FixedMath.Atan2(a, FixedMath.Sqrt((FixedNumber.ONE + a) * (FixedNumber.ONE - a)))
end

FixedMath.Acos = function(a)
    return FixedMath.Atan2(FixedMath.Sqrt((FixedNumber.ONE + a) * (FixedNumber.ONE - a)), a)
end

FixedMath.Atan = function(a)
    return FixedMath.Atan2(a, FixedNumber.ONE)
end

local ATAN2_P1 = FixedNumber.FromRaw(FixedConsts.ATAN2_P1)
local ATAN2_P2 = FixedNumber.FromRaw(FixedConsts.ATAN2_P2)
local ATAN2_P3 = FixedNumber.FromRaw(FixedConsts.ATAN2_P3)

FixedMath.Atan2 = function(b, a)
    local x = FixedMath.Abs(a)
    local y = FixedMath.Abs(b)
    local t
    if x > y then
        t = y / x
    else
        t = x / y
    end
    local s = t * t
    local r = ((ATAN2_P1 * s + ATAN2_P2) * s - ATAN2_P3) * s * t + t
    if y > x then
        r = FixedMath.HALF_PI - r
    end
    if a < FixedNumber.ZERO then
        r = FixedMath.PI - r
    end
    if b < FixedNumber.ZERO then
        r = -r
    end
    return r
end

return FixedMath