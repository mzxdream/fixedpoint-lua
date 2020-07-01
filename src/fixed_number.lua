local FixedNumber = {}

local function checkInt(x)
    local _, dec = math.modf(x)
    assert(dec == 0)
end

local function toInt(x)
    local t = math.modf(x)
    return t
end

FixedNumber.FRACTIONAL_BITS = 24
FixedNumber.FRACTIONAL_BASE = 1 << FixedNumber.FRACTIONAL_BITS
FixedNumber.FRACTIONAL_MASK = (1 << FixedNumber.FRACTIONAL_BITS) - 1
FixedNumber.FRACTIONAL_HALF = (1 << (FixedNumber.FRACTIONAL_BITS - 1))

FixedNumber.FromRaw = function(val)
    checkInt(val)
    local t = {
        val = val,
    }
    setmetatable(t, FixedNumber)
    return t
end

FixedNumber.FromDouble = function(val)
    return FixedNumber.FromRaw(toInt((val or 0) * FixedNumber.FRACTIONAL_BASE))
end

FixedNumber.FromFraction = function(numerator, denominator)
    checkInt(numerator)
    checkInt(denominator)
    if numerator >= 0 then
        if denominator > 0 then
            return FixedNumber.FromRaw(((numerator << (FixedNumber.FRACTIONAL_BITS + 1)) // denominator + 1) >> 1)
        elseif denominator < 0 then
            return FixedNumber.FromRaw(-(((numerator << (FixedNumber.FRACTIONAL_BITS + 1)) // -denominator + 1) >> 1))
        end
    else
        if denominator > 0 then
            return FixedNumber.FromRaw(-(((-numerator << (FixedNumber.FRACTIONAL_BITS + 1)) // denominator + 1) >> 1))
        elseif denominator < 0 then
            return FixedNumber.FromRaw(((-numerator << (FixedNumber.FRACTIONAL_BITS + 1)) // (-denominator) + 1) >> 1)
        end
    end
end

FixedNumber.Get = function(a)
    return a.val
end

FixedNumber.Clone = function(a)
    return FixedNumber.FromRaw(a.val)
end

FixedNumber.Copy = function(a, b)
    a.val = b.val
end

FixedNumber.ToInt = function(a)
    if a.val >= 0 then
        return a.val >> FixedNumber.FRACTIONAL_BITS
    else
        return -(-a.val >> FixedNumber.FRACTIONAL_BITS)
    end
end

FixedNumber.ToDouble = function(a)
    return a.val / FixedNumber.FRACTIONAL_BASE
end

FixedNumber.ToFloor = function(a)
    if a.val >= 0 then
        return a.val >> FixedNumber.FRACTIONAL_BITS
    else
        return -((-a.val + FixedNumber.FRACTIONAL_MASK) >> FixedNumber.FRACTIONAL_BITS)
    end
end

FixedNumber.ToCeil = function(a)
    if a.val >= 0 then
        return (a.val + FixedNumber.FRACTIONAL_MASK) >> FixedNumber.FRACTIONAL_BITS
    else
        return -(-a.val >> FixedNumber.FRACTIONAL_BITS)
    end
end

FixedNumber.ToRound = function(a)
    if a.val >= 0 then
        return (a.val + FixedNumber.FRACTIONAL_HALF) >> FixedNumber.FRACTIONAL_BITS
    else
        return -((-a.val + FixedNumber.FRACTIONAL_HALF) >> FixedNumber.FRACTIONAL_BITS)
    end
end

FixedNumber.__index = FixedNumber

FixedNumber.__tostring = function(a)
    return tostring(a:ToDouble())
end

FixedNumber.__add = function(a, b)
    return FixedNumber.FromRaw(a.val + b.val)
end

FixedNumber.__sub = function(a, b)
    return FixedNumber.FromRaw(a.val - b.val)
end

FixedNumber.__mul = function(a, b)
    local x = math.abs(a.val)
    local y = math.abs(b.val)
    local x1 = x >> FixedNumber.FRACTIONAL_BITS;
    local x2 = x & FixedNumber.FRACTIONAL_MASK;
    local y1 = y >> FixedNumber.FRACTIONAL_BITS;
    local y2 = y & FixedNumber.FRACTIONAL_MASK;
    if (a.val < 0 and b.val > 0) or (a.val > 0 and b.val < 0) then
        return FixedNumber.FromRaw(-(((x1 * y1) << FixedNumber.FRACTIONAL_BITS) + x1 * y2 + x2 * y1 + ((x2 * y2 + FixedNumber.FRACTIONAL_HALF) >> FixedNumber.FRACTIONAL_BITS)))
    else
        return FixedNumber.FromRaw(((x1 * y1) << FixedNumber.FRACTIONAL_BITS) + x1 * y2 + x2 * y1 + ((x2 * y2 + FixedNumber.FRACTIONAL_HALF) >> FixedNumber.FRACTIONAL_BITS))
    end
end

FixedNumber.__div = function(a, b)
    local dividend = math.abs(a.val)
    local divisor =  math.abs(b.val)
    local result = 0
    for i = 0, FixedNumber.FRACTIONAL_BITS do
        local t = dividend // divisor
        if t > 0 then
            result = result + (t << (FixedNumber.FRACTIONAL_BITS + 1 - i))
            dividend = dividend % divisor
        end
        dividend = dividend << 1
    end
    if (a.val < 0 and b.val > 0) or (a.val > 0 and b.val < 0) then
        return FixedNumber.FromRaw(-((result + 1) >> 1))
    else
        return FixedNumber.FromRaw((result + 1) >> 1)
    end
end

FixedNumber.__unm = function(a)
    return FixedNumber.FromRaw(-a.val)
end

FixedNumber.__eq = function(a, b)
    return a.val == b.val
end

FixedNumber.__lt = function(a, b)
    return a.val < b.val
end

FixedNumber.__le = function(a, b)
    return a.val <= b.val
end

FixedNumber.EPS         = FixedNumber.FromRaw(1)
FixedNumber.MIN         = FixedNumber.FromRaw(-2^53)
FixedNumber.MAX         = FixedNumber.FromRaw(2^53)
FixedNumber.NEG_ONE     = FixedNumber.FromRaw(-FixedNumber.FRACTIONAL_BASE)
FixedNumber.NEG_TWO     = FixedNumber.FromRaw(-2 * FixedNumber.FRACTIONAL_BASE)
FixedNumber.ZERO        = FixedNumber.FromRaw(0)
FixedNumber.HALF        = FixedNumber.FromRaw(FixedNumber.FRACTIONAL_HALF)
FixedNumber.ONE         = FixedNumber.FromRaw(FixedNumber.FRACTIONAL_BASE)
FixedNumber.TWO         = FixedNumber.FromRaw(2 * FixedNumber.FRACTIONAL_BASE)
FixedNumber.FOUR        = FixedNumber.FromRaw(4 * FixedNumber.FRACTIONAL_BASE)
FixedNumber.NUM90       = FixedNumber.FromRaw(90 * FixedNumber.FRACTIONAL_BASE)
FixedNumber.NUM180      = FixedNumber.FromRaw(180 * FixedNumber.FRACTIONAL_BASE)
FixedNumber.NUM270      = FixedNumber.FromRaw(270 * FixedNumber.FRACTIONAL_BASE)
FixedNumber.NUM360      = FixedNumber.FromRaw(360 * FixedNumber.FRACTIONAL_BASE)
FixedNumber.NUM255      = FixedNumber.FromRaw(255 * FixedNumber.FRACTIONAL_BASE)
FixedNumber.DOT1        = FixedNumber.FromRaw(FixedConsts.DOT1)
FixedNumber.DOT01       = FixedNumber.FromRaw(FixedConsts.DOT01)
FixedNumber.DOT001      = FixedNumber.FromRaw(FixedConsts.DOT001)
FixedNumber.DOT0001     = FixedNumber.FromRaw(FixedConsts.DOT0001)
FixedNumber.DOT00001    = FixedNumber.FromRaw(FixedConsts.DOT00001)
FixedNumber.DOT000001   = FixedNumber.FromRaw(FixedConsts.DOT000001)

return FixedNumber