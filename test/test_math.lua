local function TestClamp(count)
    local diff_a = 0.0
    local diff_b = 0.0
    local diff_c = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local b = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local c = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        if b > c then
            b, c = c, b
        end
        local t1 = math.min(math.max(a, b), c)
        local t2 = FixedMath.Clamp(FixedNumber.FromDouble(a), FixedNumber.FromDouble(b), FixedNumber.FromDouble(c))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_a = a
            diff_b = b
            diff_c = c
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestClamp i:", i, " a:", t1, " t1:", t1, " t2", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestClamp count:", count, " diff max:", diff_max, " diff a:", diff_a, " b:", diff_b, " c:", diff_c, " diff count:", diff_count)
end

local function TestPow(count)
    local diff_i = 0
    local diff_a = 0.0
    local diff_n = 0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local n = RandInt(-5, 5)
        local t1 = math.pow(a, n)
        while math.abs(t1) >= FIXED_DBL_MAX - 1 do
            a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
            n = RandInt(-5, 5)
            t1 = math.pow(a, n)
        end
        local t2 = FixedMath.Pow(FixedNumber.FromDouble(a), n)
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_i = i
            diff_max = diff
            diff_a = a
            diff_n = n
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestPow i:", i, " a:", a, " n:", n, " t1:", t1, " t2", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestPow count:", count, " diff i:", diff_i, " diff max:", diff_max, " a:", diff_a, " n:", diff_n, " diff count:", diff_count)
end

local function TestMin(count)

    local diff_i = 0
    local diff_a = 0.0
    local diff_b = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local b = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = math.min(a, b)
        local t2 = FixedMath.Min(FixedNumber.FromDouble(a), FixedNumber.FromDouble(b))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_i = i
            diff_max = diff
            diff_a = a
            diff_b = b
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestMin i:", i, " a:", a, " b:", b, " t1:", t1, " t2", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestMin count:", count, " diff i:", diff_i, " diff max:", diff_max, " a:", diff_a, " b:", diff_b, " diff count:", diff_count)
end

local function TestMax(count)
    local diff_i = 0
    local diff_a = 0.0
    local diff_b = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local b = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = math.max(a, b)
        local t2 = FixedMath.Max(FixedNumber.FromDouble(a), FixedNumber.FromDouble(b))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_i = i
            diff_max = diff
            diff_a = a
            diff_b = b
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestMax i:", i, " a:", a, " b:", b, " t1:", t1, " t2", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestMax count:", count, " diff i:", diff_i, " diff max:", diff_max, " a:", diff_a, " b:", diff_b, " diff count:", diff_count)
end

local function TestAbs(count)
    local diff_i = 0
    local diff_a = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = a
        if t1 < 0 then
            t1 = -t1
        end
        local t2 = FixedMath.Abs(FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_i = i
            diff_max = diff
            diff_a = a
        end
        if diff >= EPSION then
        
            diff_count = diff_count + 1
            print("TestAbs i:", i, " a:", a, " t1:", t1, " t2", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestAbs count:", count, " diff i:", diff_i, " diff max:", diff_max, " a:", diff_a, " diff count:", diff_count)
end

local function TestSqrt(count)
    local diff_num = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
    
        local a = RandDouble(0.0001, FIXED_DBL_MAX)
        local t1 = math.sqrt(a)
        local t2 = FixedMath.Sqrt(FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_num = a
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestSqrt i:", i, " a:", a, " t1:", t1, " t2", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestSqrt count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestRad2Deg(count)
    local diff_num = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = a * 180 / 3.14159265358979323846
        t1 = t1 - math.floor(t1 / 360) * 360
        local t2 = FixedMath.Rad2Deg(FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_num = a
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestRad2Deg i:", i, " a:", a, " t1:", t1, " t2", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestRad2Deg count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestDeg2Rad(count)
    local diff_num = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = a - math.floor(a / 360) * 360
        t1 = t1 * 3.14159265358979323846 / 180
        local t2 = FixedMath.Deg2Rad(FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_num = a
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestDeg2Rad i:", i, " a:", a, " t1:", t1, " t2", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestDeg2Rad count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestSinDeg(count)
    local diff_num = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX) / 2
        local t1 = math.sin(a * 3.14159265358979323846 / 180)
        local t2 = FixedMath.SinDeg(FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_num = a
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestSinDeg i:", i, " a:", a, " t1:", t1, " t2", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestSinDeg count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestCosDeg(count)
    local diff_num = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX) / 2
        local t1 = math.cos(a * 3.14159265358979323846 / 180)
        local t2 = FixedMath.CosDeg(FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_num = a
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestCosDeg i:", i, " a:", a, " t1:", t1, " t2", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestCosDeg count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestSin(count)
    local diff_num = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = math.sin(a)
        local t2 = FixedMath.Sin(FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_num = a
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestSin i:", i, " a:", a, " t1:", t1, " t2", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestSin count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestCos(count)
    local diff_num = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = math.cos(a)
        local t2 = FixedMath.Cos(FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_num = t1
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestCos i:", i, " a:", a, " t1:", t1, " t2", t2:ToDouble(), " diff:", t1 - t2:ToDouble())
        end
    end
    print("TestCos count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestAsin(count)
    local diff_num = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(-1.0, 1.0)
        local t1 = math.asin(a)
        local t2 = FixedMath.Asin(FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_num = t1
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestAsin i:", i, " a:", a, " t1:", t1, " t2", t2:ToDouble(), " diff:", t1 - t2:ToDouble())
        end
    end
    print("TestAsin count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestAcos(count)

    local diff_num = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(-1.0, 1.0)
        local t1 = math.acos(a)
        local t2 = FixedMath.Acos(FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_num = t1
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestAcos i:", i, " a:", a, " t1:", t1, " t2", t2:ToDouble(), " diff:", t1 - t2:ToDouble())
        end
    end
    print("TestAcos count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestAtan(count)
    local diff_num = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = math.atan(a)
        local t2 = FixedMath.Atan(FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_num = t1
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestAtan i:", i, " a:", a, " t1:", t1, " t2", t2:ToDouble(), " diff:", t1 - t2:ToDouble())
        end
    end
    print("TestAtan count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestAtan2(count)
    local diff_a = 0.0
    local diff_b = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local b = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        while math.abs(a) < 0.000001 and math.abs(b) < 0.000001 do
            a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
            b = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        end
        local t1 = math.atan2(b, a)
        local t2 = FixedMath.Atan2(FixedNumber.FromDouble(b), FixedNumber.FromDouble(a))
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_a = a
            diff_b = b
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestAtan2 i:", i, " a:", a, " b:", b, " t1:", t1, " t2", t2:ToDouble(), " diff:", t1 - t2:ToDouble())
        end
    end
    print("TestAtan2 count:", count, " diff max:", diff_max, " diff a:", diff_a, " b:", diff_b, " diff count:", diff_count)
end

function TestMath(count)
    TestClamp(count)
    TestPow(count)
    TestMin(count)
    TestMax(count)
    TestAbs(count)
    TestSqrt(count)
    TestRad2Deg(count)
    TestDeg2Rad(count)
    TestSinDeg(count)
    TestCosDeg(count)
    TestSin(count)
    TestCos(count)
    TestAsin(count)
    TestAcos(count)
    TestAtan(count)
    TestAtan2(count)
end