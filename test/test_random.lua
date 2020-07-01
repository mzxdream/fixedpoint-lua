function TestRand(count)
    local rand = FixedRandom.New(123)
    for i = 0, count - 1 do
        print("rand:", rand:Rand())
    end
    for i = 0, count - 1 do
        print("rand(-100~100):", rand:Rand(-100, 100))
    end
    for i = 0, count - 1 do
        print("randNumber:", rand:RandNumber():ToDouble())
    end
    for i = 0, count - 1 do
        print("randNumber:", rand:RandNumber(FixedNumber.FromDouble(-1.0), FixedNumber.FromDouble(1.0)):ToDouble())
    end
end