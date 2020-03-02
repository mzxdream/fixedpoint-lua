local FixedMath = {}

local FixedNumber = require("fixed_number")
local FixedMathTable = require("fixed_math_table")

local FIXED_EPS = FixedNumber.FIXED_EPS
local FIXED_ZERO = FixedNumber.FIXED_ZERO
local FIXED_ONE = FixedNumber.FIXED_ONE
local FIXED_TWO = FixedNumber.FIXED_TWO
local FIXED_NEG_ONE = FixedNumber.FIXED_NEG_ONE

FixedMath.FIXED_PI = FixedNumber.New(3.1415926536);
FixedMath.FIXED_RAD2DEG = FixedNumber.New(57.295779513);
FixedMath.FIXED_DEG2RAD = FIXED_ONE / FixedMath.FIXED_RAD2DEG;

FixedMath.FixedInt = function(a)
    return a:ToInt()
end

FixedMath.FixedFloor = function(a)
    return a:ToFloor()
end

FixedMath.FixedCeil = function(a)
    return a:ToCeil()
end

FixedMath.FixedRound = function(a)
    return a:ToRound()
end

FixedMath.FixedClamp = function(a, mina, maxa)
    if a < mina then
        return FixedNumber.New(mina)
    elseif a > maxa then
        return FixedNumber.New(maxa)
    else
        return FixedNumber.New(a)
    end
end

FixedMath.FixedPow = function(a, n)
    if n == 0 then
        return FixedNumer.New(1)
    elseif n == 1 or a == FIXED_ZERO or a == FIXED_ONE then
        return FixedNumber.New(a)
    elseif n < 0 then
        return FixedMath.FixedPow(FIXED_ONE / a, -n)
    elseif n & 1 == 1 then
        return FixedMath.FixedPow(a * a, n >> 1) * a
    else
        return FixedMath.FixedPow(a * a, n >> 1)
    end
end

FixedMath.FixedMin = function(a, b)
    if a < b then
        return FixedNumber.New(a)
    else
        return FixedNumber.New(b)
    end
end

FixedMath.FixedMax = function(a, b)
    if a < b then
        return FixedNumber.New(b)
    else
        return FixedNumber.New(a)
    end
end

FixedMath.FixedAbs = function(a)
    if a < FIXED_ZERO then
        return -a
    else
        return FixedNumber.New(a)
    end
end

FixedMath.FixedSqrt = function(a)
    if a <= FIXED_ZERO then
        return FixedNumber.New(FIXED_ZERO)
    elseif a == FIXED_ONE then
        return FixedNumber.New(FIXED_ONE)
    end
    local t = FixedNumber.New(a)
    local c = FIXED_ZERO
    while FixedMath.FixedAbs(t - c) > FIXED_EPS do
        c = t
        t = (t + a / t) / FIXED_TWO
    end
    return t
end

local FIXED_TWO_PI = FIXED_TWO * FixedMath.FIXED_PI

FixedMath.FixedSin = function(a)
    while a < FIXED_ZERO do
        a = a + FIXED_TWO_PI
    end
    while a >= FIXED_TWO_PI do
        a = a - FIXED_TWO_PI
    end
    a = a * FixedNumber.New(FixedMathTable.SIN_BASE) / FixedMath.FIXED_PI
    return FixedNumber.New(FixedMathTable.SIN_TABLE[FixedMath.FixedInt(a) + 1], -FixedMathTable.SIN_EXP)
end

FixedMath.FixedCos = function(a)
    while a < FIXED_ZERO do
        a = a + FIXED_TWO_PI
    end
    while a >= FIXED_TWO_PI do
        a = a - FIXED_TWO_PI
    end
    a = a * FixedNumber.New(FixedMathTable.COS_BASE) / FixedMath.FIXED_PI
    return FixedNumber.New(FixedMathTable.COS_TABLE[FixedMath.FixedInt(a) + 1], -FixedMathTable.COS_EXP)
end

local FIXED_HALF_PI = FixedMath.FIXED_PI / FIXED_TWO

FixedMath.FixedAsin = function(a)
    return FIXED_HALF_PI - FixedMath.FixedAcos(a)
end

FixedMath.FixedAcos = function(a)
    if a < FIXED_NEG_ONE or a > FIXED_ONE then
        return FixedNumber.New(FIXED_ZERO)
    end
    a = a * FixedNumber.New(FixedMathTable.ACOS_BASE) + FixedNumber.New(FixedMathTable.ACOS_BASE);
    return FixedNumber.New(FixedMathTable.ACOS_TABLE[FixedMath.FixedInt(a) + 1], -FixedMathTable.ACOS_EXP)
end

local FIXED_ATAN2_P1 = FixedNumber.New(-0.0464964749);
local FIXED_ATAN2_P2 = FixedNumber.New(0.15931422);
local FIXED_ATAN2_P3 = FixedNumber.New(0.327622764);

FixedMath.FixedAtan2 = function(b, a)
    local x = FixedMath.FixedAbs(a)
    local y = FixedMath.FixedAbs(b)
    local t = FixedMath.FixedMin(x, y) / FixedMath.FixedMax(x, y)
    local s = t * t
    local r = ((FIXED_ATAN2_P1 * s + FIXED_ATAN2_P2) * s - FIXED_ATAN2_P3) * s * t + t
    if y > x then
        r = FIXED_HALF_PI - r
    end
    if a < FIXED_ZERO then
        r = FIXED_PI - r
    end
    if b < FIXED_ZERO then
        r = -r
    end
    return r
end

return FixedMath
