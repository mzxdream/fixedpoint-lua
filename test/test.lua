package.path = "../src/?.lua;"..package.path
require('fixed_import')

EPSION = 0.000001
FIXED_DBL_MIN = FixedNumber.MIN:ToDouble() + 1
FIXED_DBL_MAX = FixedNumber.MAX:ToDouble() - 1
FIXED_INT_MIN = FixedNumber.MIN:ToInt() + 1
FIXED_INT_MAX = FixedNumber.MAX:ToInt() - 1

math.randomseed(os.time())

function RandInt(mina, maxa)
    return math.random(mina, maxa)
end

function RandDouble(mina, maxa)
    return mina + (maxa - mina) * math.random()
end

require('test_number')
require('test_math')
require('test_random')

local count = 10000
--TestNumber(count)
--TestMath(count)
TestRand(count)