package.path = "../src/?.lua;"..package.path
require('fixed_import')

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

print(FixedMath.ToInt(a))
print(FixedMath.ToInt(b))

print(FixedMath.Floor(FixedNumber.New(-1.1)))
print(FixedMath.Floor(FixedNumber.New(1.1)))

print(FixedMath.Ceil(FixedNumber.New(1.1)))
print(FixedMath.Ceil(FixedNumber.New(-1.1)))


print(FixedMath.Round(FixedNumber.New(1.45)))
print(FixedMath.Round(FixedNumber.New(1.51)))
print(FixedMath.Round(FixedNumber.New(-1.45)))
print(FixedMath.Round(FixedNumber.New(-1.51)))

print(FixedMath.Clamp(a, FixedNumber.ZERO, b))

print(FixedMath.Pow(a, 3))
print(FixedMath.Pow(FixedNumber.New(1.123), -4))

print(FixedMath.Min(a, b))
print(FixedMath.Max(a, b))

print(FixedMath.Abs(a))

print(FixedMath.Sqrt(a))
print(math.sqrt(a:Raw()))

print(FixedMath.Sin(a))
print(math.sin(a:Raw()))

print(FixedMath.Cos(a))
print(math.cos(a:Raw()))

print(FixedMath.Asin(FixedNumber.New(0.6)))
print(math.asin(0.6))

print(FixedMath.Acos(FixedNumber.New(0.7)))
print(math.acos(0.7))

print(FixedMath.Atan2(b, a))
print(math.atan2(b:Raw(), a:Raw()))
