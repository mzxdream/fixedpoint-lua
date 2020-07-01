local function TestFromDouble(count)
    local diff_num = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count-1 do
        local t1 = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t2 = FixedNumber.FromDouble(t1)
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_num = t1
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestFromDouble i:", i, " a:", t1, " t1:", t1, " t2:", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestFromDouble count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestFromFraction(count)
    local diff_a = 0
    local diff_b = 0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count-1 do
        local a = RandInt(FIXED_INT_MIN, FIXED_INT_MAX)
        local b = RandInt(FIXED_INT_MIN, FIXED_INT_MAX)
        while b == 0 do
            b = RandInt(FIXED_INT_MIN, FIXED_INT_MAX)
        end
        local t1 = a / b
        local t2 = FixedNumber.FromFraction(a, b)
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_a = a
            diff_b = b
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestFromFraction i:", i, " a:", a, " b:", b, " t1:", t1, " t2:", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestFromFraction count:", count, " diff max:", diff_max, " diff a:", diff_a, " b:", diff_b, " diff count:", diff_count)
end

local function TestToInt(count)
    local diff_num = 0
    local diff_max = 0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1
        if a >= 0 then
            t1 = math.floor(a)
        else
            t1 = math.ceil(a)
        end
        local p = FixedNumber.FromDouble(a)
        local t2 = p:ToInt()
        local diff = math.abs(t1 - t2)
        if diff_max < diff then
            diff_max = diff
            diff_num = t1
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestToInt i:", i, " a:", a, " t1:", t1, " t2:", t2, " diff:", diff)
        end
    end
    print("TestToInt count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestToFloor(count)
    local diff_num = 0
    local diff_max = 0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = math.floor(a)
        local p = FixedNumber.FromDouble(a)
        local t2 = p:ToFloor()
        local diff = math.abs(t1 - t2)
        if diff_max < diff then
            diff_max = diff
            diff_num = t1
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestToFloor i:", i, " a:", a, " t1:", t1, " t2:", t2, " diff:", diff)
        end
    end
    print("TestToFloor count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestToCeil(count)
    local diff_num = 0
    local diff_max = 0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = math.ceil(a)
        local p = FixedNumber.FromDouble(a)
        local t2 = p:ToCeil()
        local diff = math.abs(t1 - t2)
        if diff_max < diff then
            diff_max = diff
            diff_num = t1
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestToCeil i:", i, " a:", a, " t1:", t1, " t2:", t2, " diff:", diff)
        end
    end
    print("TestToCeil count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

local function TestToRound(count)
    local diff_num = 0
    local diff_max = 0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = round(a)
        local p = FixedNumber.FromDouble(a)
        local t2 = p:ToRound()
        local diff = math.abs(t1 - t2)
        if diff_max < diff then
            diff_max = diff
            diff_num = t1
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestToRound i:", i, " a:", a, " t1:", t1, " t2:", t2, " diff:", diff)
        end
    end
    print("TestToRound count:", count, " diff max:", diff_max, " diff num:", diff_num, " diff count:", diff_count)
end

local function TestAdd(count)
    local diff_a = 0.0
    local diff_b = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local b = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = a + b
        while math.abs(t1) >= FIXED_DBL_MAX - 1 do
            a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
            b = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
            t1 = a + b
        end
        local t2 = FixedNumber.FromDouble(a) + FixedNumber.FromDouble(b)
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_a = a
            diff_b = b
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestAdd a:", a, " b:", b, " t1:", t1, " t2:", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestAdd count:", count, " diff max:", diff_max, " diff a:", diff_a, " diff b:", diff_b, " diff count:", diff_count)
end

local function TestSub(count)
    local diff_a = 0.0
    local diff_b = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0,  count - 1 do
        local a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local b = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
        local t1 = a - b
        while math.abs(t1) >= FIXED_DBL_MAX - 1 do
            a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
            b = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX)
            t1 = a - b
        end
        local t2 = FixedNumber.FromDouble(a) - FixedNumber.FromDouble(b)
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_a = a
            diff_b = b
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestSub a:", a, " b:", b, " t1:", t1, " t2:", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestSub count:", count, " diff max:", diff_max, " diff a:", diff_a, " diff b:", diff_b, " diff count:", diff_count)
end

local function TestMul(count)
    local diff_a = 0.0
    local diff_b = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1)
        local b = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1)
        local t1 = a * b
        while math.abs(t1) >= FIXED_DBL_MAX - 1 do
            a = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1)
            b = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1)
            t1 = a * b
        end
        local t2 = FixedNumber.FromDouble(a) * FixedNumber.FromDouble(b)
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_a = a
            diff_b = b
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestMul a:", a, " b:", b, " t1:", t1, " t2:", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestMul count:", count, " diff max:", diff_max, " diff a:", diff_a, " diff b:", diff_b, " diff count:", diff_count)
end

local function TestDiv(count)
    local diff_a = 0.0
    local diff_b = 0.0
    local diff_max = 0.0
    local diff_count = 0
    for i = 0, count - 1 do
        local a = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1)
        local b = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1)
        local t1 = a / b
        while math.abs(t1) >= FIXED_DBL_MAX - 1 do
            a = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1)
            b = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1)
            t1 = a / b
        end
        local t2 = FixedNumber.FromDouble(a) / FixedNumber.FromDouble(b)
        local diff = math.abs(t1 - t2:ToDouble())
        if diff_max < diff then
            diff_max = diff
            diff_a = a
            diff_b = b
        end
        if diff >= EPSION then
            diff_count = diff_count + 1
            print("TestDiv a:", a, " b:", b, " t1:", t1, " t2:", t2:ToDouble(), " diff:", diff)
        end
    end
    print("TestDiv count:", count, " diff max:", diff_max, " diff a:", diff_a, " diff b:", diff_b, " diff count:", diff_count)
end

function TestNumber(count)
    TestFromDouble(count)
    TestFromFraction(count)
    TestToInt(count)
    TestToFloor(count)
    TestToCeil(count)
    TestToRound(count)
    TestAdd(count)
    TestSub(count)
    TestMul(count)
    TestDiv(count)
end