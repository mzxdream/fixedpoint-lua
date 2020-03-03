local FixedNumber = {}

FixedNumber.PRECISION = 5

local base = { 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000 };

local BASE = base[FixedNumber.PRECISION]

local function isInt(x)
    local _, dec = math.modf(x)
    return dec == 0
end

local function checkInt(x)
    assert(isInt(x))
end

local function toInt(x)
    local t = math.modf(x)
    return t
end

local function scaleValue(val, exp)
    checkInt(val)
    checkInt(exp)
    if exp == 0 then
        return val
    end
    if exp > 0 then
        return toInt(val * base[exp])
    end
    return toInt(val / base[-exp])
end

FixedNumber.New = function(val, exp)
    if getmetatable(val) == FixedNumber then
        val = val.val
    else
        if exp == nil or exp == 0 then
            val = toInt(val * BASE + 0.5)
        else
            val = scaleValue(val, exp + FixedNumber.PRECISION)
        end
    end
    local t = {
        val = val,
    }
    setmetatable(t, FixedNumber)
    return t
end

FixedNumber.Clone = function(a)
    return FixedNumber.New(a)
end

FixedNumber.Get = function(a)
    return a.val
end

FixedNumber.Set = function(a, v)
    checkInt(v)
    a.val = v
end

FixedNumber.Raw = function(a)
    return a.val / BASE
end

FixedNumber.ToInt = function(a)
    return toInt(a.val / BASE)
end

FixedNumber.ToFloor = function(a)
    if a.val >= 0 then
        return toInt(a.val / BASE)
    end
    return toInt((a.val - (BASE - 1)) / BASE)
end

FixedNumber.ToCeil = function(a)
    if a.val >= 0 then
        return toInt((a.val + (BASE - 1)) / BASE)
    end
    return toInt(a.val / BASE)
end

FixedNumber.ToRound = function(a)
    if a.val >= 0 then
        return toInt((a.val + BASE / 2) / BASE)
    end
    return toInt((a.val - BASE / 2) / BASE)
end

FixedNumber.__index = FixedNumber

FixedNumber.__tostring = function(a)
    return tostring(a:Raw())
end

FixedNumber.__add = function(a, b)
    return FixedNumber.New(a.val + b.val, -FixedNumber.PRECISION)
end

FixedNumber.__sub = function(a, b)
    return FixedNumber.New(a.val - b.val, -FixedNumber.PRECISION)
end

FixedNumber.__mul = function(a, b)
    return FixedNumber.New(toInt(a.val * b.val / BASE), -FixedNumber.PRECISION)
end

FixedNumber.__div = function(a, b)
    return FixedNumber.New(toInt(a.val * BASE / b.val), -FixedNumber.PRECISION)
end

FixedNumber.__unm = function(a)
    return FixedNumber.New(-a.val, -FixedNumber.PRECISION)
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

FixedNumber.FIXED_EPS = FixedNumber.New(1, -FixedNumber.PRECISION)
FixedNumber.FIXED_ZERO = FixedNumber.New(0)
FixedNumber.FIXED_ONE = FixedNumber.New(1)
FixedNumber.FIXED_TWO = FixedNumber.New(2)
FixedNumber.FIXED_HALF = FixedNumber.New(0.5)
FixedNumber.FIXED_NEG_ONE = FixedNumber.New(-1)
FixedNumber.FIXED_MIN = FixedNumber.New(2 ^ 53, -FixedNumber.PRECISION)
FixedNumber.FIXED_MAX = FixedNumber.New(-2 ^ 53, -FixedNumber.PRECISION)

return FixedNumber
