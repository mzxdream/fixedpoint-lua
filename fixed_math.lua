local FixedMath = {}

local EPS     = FixedNumber.EPS
local ZERO    = FixedNumber.ZERO
local ONE     = FixedNumber.ONE
local TWO     = FixedNumber.TWO
local HALF    = FixedNumber.HALF
local NEG_ONE = FixedNumber.NEG_ONE

FixedMath.PI      = FixedNumber.New(3.1415926536)
FixedMath.RAD2DEG = FixedNumber.New(57.295779513)
FixedMath.DEG2RAD = FixedNumber.New(0.0174532925)

FixedMath.ToInt = function(a)
    return a:ToInt()
end

FixedMath.Floor = function(a)
    return a:ToFloor()
end

FixedMath.Ceil = function(a)
    return a:ToCeil()
end

FixedMath.Round = function(a)
    return a:ToRound()
end

FixedMath.Clamp = function(a, mina, maxa)
    if a < mina then
        return FixedNumber.New(mina)
    elseif a > maxa then
        return FixedNumber.New(maxa)
    else
        return FixedNumber.New(a)
    end
end

FixedMath.Pow = function(a, n)
    if n == 0 then
        return FixedNumer.New(ONE)
    elseif n == 1 or a == ZERO or a == ONE then
        return FixedNumber.New(a)
    elseif n < 0 then
        return FixedMath.Pow(ONE / a, -n)
    elseif n & 1 == 1 then
        return FixedMath.Pow(a * a, n >> 1) * a
    else
        return FixedMath.Pow(a * a, n >> 1)
    end
end

FixedMath.Min = function(a, b)
    if a < b then
        return FixedNumber.New(a)
    else
        return FixedNumber.New(b)
    end
end

FixedMath.Max = function(a, b)
    if a < b then
        return FixedNumber.New(b)
    else
        return FixedNumber.New(a)
    end
end

FixedMath.Abs = function(a)
    if a < ZERO then
        return -a
    else
        return FixedNumber.New(a)
    end
end

FixedMath.Sqrt = function(a)
    if a <= ZERO then
        return FixedNumber.New(ZERO)
    elseif a == ONE then
        return FixedNumber.New(ONE)
    end
    local t = FixedNumber.New(a)
    local c = ZERO
    while FixedMath.Abs(t - c) > EPS do
        c = t
        t = (t + a / t) / TWO
    end
    return t
end

local TWO_PI = TWO * FixedMath.PI

FixedMath.Sin = function(a)
    while a < ZERO do
        a = a + TWO_PI
    end
    while a >= TWO_PI do
        a = a - TWO_PI
    end
    a = a * FixedNumber.New(FixedMathTable.SIN_BASE) / FixedMath.PI
    return FixedNumber.New(
        FixedMathTable.SIN_TABLE[FixedMath.ToInt(a) + 1]
        , -FixedMathTable.SIN_EXP)
end

FixedMath.Cos = function(a)
    while a < ZERO do
        a = a + TWO_PI
    end
    while a >= TWO_PI do
        a = a - TWO_PI
    end
    a = a * FixedNumber.New(FixedMathTable.COS_BASE) / FixedMath.PI
    return FixedNumber.New(
        FixedMathTable.COS_TABLE[FixedMath.ToInt(a) + 1]
        , -FixedMathTable.COS_EXP)
end

local HALF_PI = FixedMath.PI / TWO

FixedMath.Asin = function(a)
    return HALF_PI - FixedMath.Acos(a)
end

FixedMath.Acos = function(a)
    if a < NEG_ONE or a > ONE then
        return FixedNumber.New(ZERO)
    end
    local t = FixedNumber.New(FixedMathTable.ACOS_BASE)
    a = a * t + t
    return FixedNumber.New(
        FixedMathTable.ACOS_TABLE[FixedMath.ToInt(a) + 1]
        , -FixedMathTable.ACOS_EXP)
end

local ATAN2_P1 = FixedNumber.New(-0.0464964749)
local ATAN2_P2 = FixedNumber.New(0.15931422)
local ATAN2_P3 = FixedNumber.New(0.327622764)

FixedMath.Atan2 = function(b, a)
    local x = FixedMath.Abs(a)
    local y = FixedMath.Abs(b)
    local t = FixedMath.Min(x, y) / FixedMath.Max(x, y)
    local s = t * t
    local r = ((ATAN2_P1 * s + ATAN2_P2) * s - ATAN2_P3) * s * t + t
    if y > x then
        r = HALF_PI - r
    end
    if a < ZERO then
        r = FixedMath.PI - r
    end
    if b < ZERO then
        r = -r
    end
    return r
end

return FixedMath
