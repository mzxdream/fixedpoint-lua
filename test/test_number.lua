require('test_inl')

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
    auto diff_max = 0.0;
    int diff_count = 0;
    for (int i = 0; i < count; i++)
    {
        auto a = RandInt(FIXED_INT_MIN, FIXED_INT_MAX);
        auto b = RandInt(FIXED_INT_MIN, FIXED_INT_MAX);
        if (b == 0)
        {
            --i;
            continue;
        }
        auto t1 = static_cast<double>(a) / b;
        auto t2 = FixedNumber::FromFraction(a, b);
        auto diff = abs(t1 - t2.ToDouble());
        if (diff_max < diff)
        {
            diff_max = diff;
            diff_a = a;
            diff_b = b;
        }
        if (diff >= EPSION)
        {
            ++diff_count;
            std::cout << "TestFromFraction i:" << i << " a:" << a << " b:" << b
                << " t1:" << t1 << " t2:" << t2.ToDouble() << " diff:" << diff << std::endl;
        }
    }
    std::cout << "TestFromFraction count:" << count << " diff max:" << diff_max << " diff a:" << diff_a << " b:" << diff_b << " diff count:" << diff_count << std::endl;
}

void TestToInt(int count)
{
    int64_t diff_num = 0;
    int64_t diff_max = 0;
    int diff_count = 0;
    for (int i = 0; i < count; i++)
    {
        auto a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX);
        auto t1 = static_cast<int64_t>(a);
        auto p = FixedNumber::FromDouble(a);
        auto t2 = p.ToInt();
        auto diff = abs(t1 - t2);
        if (diff_max < diff)
        {
            diff_max = diff;
            diff_num = t1;
        }
        if (diff >= EPSION)
        {
            ++diff_count;
            std::cout << "TestToInt i:" << i << " a:" << a
                << " t1:" << t1 << " t2:" << t2 << " diff:" << diff << std::endl;
        }
    }
    std::cout << "TestToInt count:" << count << " diff max:" << diff_max << " diff num:" << diff_num << " diff count:" << diff_count << std::endl;
}

void TestToFloor(int count)
{
    int64_t diff_num = 0;
    int64_t diff_max = 0;
    int diff_count = 0;
    for (int i = 0; i < count; i++)
    {
        auto a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX);
        auto t1 = static_cast<int64_t>(floor(a));
        auto p = FixedNumber::FromDouble(a);
        auto t2 = p.ToFloor();
        auto diff = abs(t1 - t2);
        if (diff_max < diff)
        {
            diff_max = diff;
            diff_num = t1;
        }
        if (diff >= EPSION)
        {
            ++diff_count;
            std::cout << "TestToFloor i:" << i << " a:" << a
                << " t1:" << t1 << " t2:" << t2 << " diff:" << diff << std::endl;
        }
    }
    std::cout << "TestToFloor count:" << count << " diff max:" << diff_max << " diff num:" << diff_num << " diff count:" << diff_count << std::endl;
}

void TestToCeil(int count)
{
    int64_t diff_num = 0;
    int64_t diff_max = 0;
    int diff_count = 0;
    for (int i = 0; i < count; i++)
    {
        auto a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX);
        auto t1 = static_cast<int64_t>(ceil(a));
        auto p = FixedNumber::FromDouble(a);
        auto t2 = p.ToCeil();
        auto diff = abs(t1 - t2);
        if (diff_max < diff)
        {
            diff_max = diff;
            diff_num = t1;
        }
        if (diff >= EPSION)
        {
            ++diff_count;
            std::cout << "TestToCeil i:" << i << " a:" << a
                << " t1:" << t1 << " t2:" << t2 << " diff:" << diff << std::endl;
        }
    }
    std::cout << "TestToCeil count:" << count << " diff max:" << diff_max << " diff num:" << diff_num << " diff count:" << diff_count << std::endl;
}

void TestToRound(int count)
{
    int64_t diff_num = 0;
    int64_t diff_max = 0;
    int diff_count = 0;
    for (int i = 0; i < count; i++)
    {
        auto a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX);
        auto t1 = static_cast<int64_t>(round(a));
        auto p = FixedNumber::FromDouble(a);
        auto t2 = p.ToRound();
        auto diff = abs(t1 - t2);
        if (diff_max < diff)
        {
            diff_max = diff;
            diff_num = t1;
        }
        if (diff >= EPSION)
        {
            ++diff_count;
            std::cout << "TestToRound i:" << i << " a:" << a
                << " t1:" << t1 << " t2:" << t2 << " diff:" << diff << std::endl;
        }
    }
    std::cout << "TestToRound count:" << count << " diff max:" << diff_max << " diff num:" << diff_num << " diff count:" << diff_count << std::endl;
}

void TestAdd(int count)
{
    auto diff_a = 0.0;
    auto diff_b = 0.0;
    auto diff_max = 0.0;
    int diff_count = 0;
    for (int i = 0; i < count; i++)
    {
        auto a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX);
        auto b = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX);
        auto t1 = a + b;
        if (abs(t1) >= FIXED_DBL_MAX - 1)
        {
            --i;
            continue;
        }
        auto t2 = FixedNumber::FromDouble(a) + FixedNumber::FromDouble(b);
        auto diff = abs(t1 - t2.ToDouble());
        if (diff_max < diff)
        {
            diff_max = diff;
            diff_a = a;
            diff_b = b;
        }
        if (diff >= EPSION)
        {
            ++diff_count;
            std::cout << "TestAdd a:" << a << " b:" << b
                << " t1:" << t1 << " t2:" << t2.ToDouble() << " diff:" << diff << std::endl;
        }
    }
    std::cout << "TestAdd count:" << count << " diff max:" << diff_max << " diff a:" << diff_a << " diff b:" << diff_b << " diff count:" << diff_count << std::endl;
}

void TestSub(int count)
{
    auto diff_a = 0.0;
    auto diff_b = 0.0;
    auto diff_max = 0.0;
    int diff_count = 0;
    for (int i = 0; i < count; i++)
    {
        auto a = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX);
        auto b = RandDouble(FIXED_DBL_MIN, FIXED_DBL_MAX);
        auto t1 = a - b;
        if (abs(t1) >= FIXED_DBL_MAX - 1)
        {
            --i;
            continue;
        }
        auto t2 = FixedNumber::FromDouble(a) - FixedNumber::FromDouble(b);
        auto diff = abs(t1 - t2.ToDouble());
        if (diff_max < diff)
        {
            diff_max = diff;
            diff_a = a;
            diff_b = b;
        }
        if (diff >= EPSION)
        {
            ++diff_count;
            std::cout << "TestSub a:" << a << " b:" << b
                << " t1:" << t1 << " t2:" << t2.ToDouble() << " diff:" << diff << std::endl;
        }
    }
    std::cout << "TestSub count:" << count << " diff max:" << diff_max << " diff a:" << diff_a << " diff b:" << diff_b << " diff count:" << diff_count << std::endl;
}

void TestMul(int count)
{
    auto diff_a = 0.0;
    auto diff_b = 0.0;
    auto diff_max = 0.0;
    int diff_count = 0;
    for (int i = 0; i < count; i++)
    {
        auto a = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1);
        auto b = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1);
        a /= b;
        //a = -0.275013;
        //b = -5.48514e+11;
        auto t1 = a * b;
        if (abs(t1) >= FIXED_DBL_MAX - 1)
        {
            --i;
            continue;
        }
        auto t2 = FixedNumber::FromDouble(a) * FixedNumber::FromDouble(b);
        auto diff = abs(t1 - t2.ToDouble());
        if (diff_max < diff)
        {
            diff_max = diff;
            diff_a = a;
            diff_b = b;
        }
        if (diff >= EPSION)
        {
            ++diff_count;
            std::cout << "TestMul a:" << a << " b:" << b
                << " t1:" << t1 << " t2:" << t2.ToDouble() << " diff:" << diff << std::endl;
        }
    }
    std::cout << "TestMul count:" << count << " diff max:" << diff_max << " diff a:" << diff_a << " diff b:" << diff_b << " diff count:" << diff_count << std::endl;
}

void TestDiv(int count)
{
    auto diff_a = 0.0;
    auto diff_b = 0.0;
    auto diff_max = 0.0;
    int diff_count = 0;
    for (int i = 0; i < count; i++)
    {
        auto a = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1);
        auto b = RandDouble(FIXED_DBL_MIN + 1, FIXED_DBL_MAX - 1);
        b = a / b;
        //a = 1.67777e+07;
        //b = 3.63729e-05;
        auto t1 = a / b;
        if (abs(t1) >= FIXED_DBL_MAX - 1)
        {
            --i;
            continue;
        }
        auto t2 = FixedNumber::FromDouble(a) / FixedNumber::FromDouble(b);
        auto diff = abs(t1 - t2.ToDouble());
        if (diff_max < diff)
        {
            diff_max = diff;
            diff_a = a;
            diff_b = b;
        }
        if (diff >= EPSION)
        {
            ++diff_count;
            std::cout << "TestDiv a:" << a << " b:" << b
                << " t1:" << t1 << " t2:" << t2.ToDouble() << " diff:" << diff << std::endl;
        }
    }
    std::cout << "TestDiv count:" << count << " diff max:" << diff_max << " diff a:" << diff_a << " diff b:" << diff_b << " diff count:" << diff_count << std::endl;
}

void TestNumber(int count)
{
    TestFromInt(count);
    TestFromDouble(count);
    TestFromFraction(count);
    TestToInt(count);
    TestToFloor(count);
    TestToCeil(count);
    TestToRound(count);
    TestAdd(count);
    TestSub(count);
    TestMul(count);
    TestDiv(count);
}