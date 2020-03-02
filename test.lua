local FixedNumber = require("fixed_number")

local a = FixedNumber.New(123)
local b = FixedNumber.New(456.789)

print(a + b)
print(a - b)
print(a * b)
print(a / b)
print(-a)
print(a == b)
print(a < b)
print(a <= b)
