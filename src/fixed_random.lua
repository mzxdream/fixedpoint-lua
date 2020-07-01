local FixedRandom = {}

--range = [0, 2^32 - 1]
FixedRandom.New = function(seed)
    local mt = {}
    mt[1] = seed
    for i = 1, 623 do
        mt[i + 1] = (0x6c078965 * (mt[i] ~ (mt[i] >> 30)) + i) & 0xffffffff
    end
    local t = {
        index = 1,
        mt = mt,
    }
    setmetatable(t, FixedRandom)
    return t
end

local function Extract(r)
    if r.index == 1 then
        for i = 0, 623 do
            local y = (r.mt[i + 1] & 0x80000000) + (r.mt[(i + 1) % 624 + 1] & 0x7fffffff)
            r.mt[i + 1] = ((y >> 1) ~ r.mt[((i + 397) % 624) + 1])
            if y % 2 ~= 0 then
                r.mt[i + 1] = r.mt[i + 1] ~ 0x9908b0df
            end
        end
    end
    local y = r.mt[r.index]
    y = y ~ (y >> 11)
    y = y ~ ((y << 7) & 0x9d2c5680)
    y = y ~ ((y << 15) & 0xefc60000)
    y = y ~ (y >> 18)
    r.index = (r.index % 624) + 1
    return y
end

local function RandUnsigned(r, a)
    if a > 2^32 - 1 then
        return ((Extract(r) % (a >> 32)) << 32) + (Extract(r) % (a & 0xFFFFFFFF))
    else
        return Extract(r) % a
    end
end

FixedRandom.Rand = function(r, a, b)
    if a == nil then
        return Extract(r)
    elseif b == nil then
        return RandUnsigned(r, a)
    elseif a < b then
        return a + RandUnsigned(r, b - a)
    else
        return b + RandUnsigned(r, a - b)
    end
end

FixedRandom.RandNumber = function(r, a, b)
    if a == nil then
        return FixedNumber.FromRaw(Extract(r) % FixedNumber.FRACTIONAL_BASE)
    elseif b == nil then
        return FixedNumber.FromRaw(RandUnsigned(r, a:Get()))
    elseif a < b then
        return FixedNumber.FromRaw(a:Get() + RandUnsigned(r, b:Get() - a:Get()))
    else
        return FixedNumber.FromRaw(b:Get() + RandUnsigned(r, a:Get() - b:Get()))
    end
end

FixedRandom.__index = FixedRandom

return FixedRandom