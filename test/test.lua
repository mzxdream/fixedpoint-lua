local FixedNumber = require("fixed_number")
local FixedMath = require("fixed_math")

local a = FixedNumber.New(123)
local b = FixedNumber.New(456.789)

--print(a + b)
--print(a - b)
--print(a * b)
--print(a / b)
--print(-a)
--print(a == b)
--print(a < b)
--print(a <= b)

print(FixedMath.FixedInt(a))
print(FixedMath.FixedInt(b))

print(FixedMath.FixedFloor(FixedNumber.New(-1.1)))
print(FixedMath.FixedFloor(FixedNumber.New(1.1)))

print(FixedMath.FixedCeil(FixedNumber.New(1.1)))
print(FixedMath.FixedCeil(FixedNumber.New(-1.1)))


print(FixedMath.FixedRound(FixedNumber.New(1.45)))
print(FixedMath.FixedRound(FixedNumber.New(1.51)))
print(FixedMath.FixedRound(FixedNumber.New(-1.45)))
print(FixedMath.FixedRound(FixedNumber.New(-1.51)))

print(FixedMath.FixedClamp(a, FixedNumber.FIXED_ZERO, b))

print(FixedMath.FixedPow(a, 3))
print(FixedMath.FixedPow(FixedNumber.New(1.123), -4))

print(FixedMath.FixedMin(a, b))
print(FixedMath.FixedMax(a, b))

print(FixedMath.FixedAbs(a))

print(FixedMath.FixedSqrt(a))
print(math.sqrt(a:Raw()))

print(FixedMath.FixedSin(a))
print(math.sin(a:Raw()))

print(FixedMath.FixedCos(a))
print(math.cos(a:Raw()))

print(FixedMath.FixedAsin(FixedNumber.New(0.6)))
print(math.asin(0.6))

print(FixedMath.FixedAcos(FixedNumber.New(0.7)))
print(math.acos(0.7))

print(FixedMath.FixedAtan2(b, a))
print(math.atan2(b:Raw(), a:Raw()))
