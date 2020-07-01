local FixedVector3 = {}

FixedVector3.New = function(x, y, z)
    local t = {
        x = x:Clone(),
        y = y:Clone(),
        z = z:Clone(),
    }
    setmetatable(t, FixedVector3)
    return t
end

FixedVector3.Clone = function(a)
    return FixedVector3.New(a.x, a.y, a.z)
end

FixedVector3.Copy = function(a, b)
    a.x:Copy(b.x)
    a.y:Copy(b.y)
    a.z:Copy(b.z)
end

FixedVector3.Get = function(a)
    return a.x, a.y, a.z
end

FixedVector3.SqrMagnitude = function(a)
    return a.x * a.x + a.y * a.y + a.z * a.z
end

FixedVector3.Magnitude = function(a)
    return FixedMath.Sqrt(a:SqrMagnitude())
end

FixedVector3.Normalize = function(a)
    local num = a:Magnitude()
    if num == FixedNumber.ZERO then
        return FixedVector3.ZERO:Clone()
    end
    return FixedVector3.New(a.x / num, a.y / num, a.z / num)
end

FixedVector3.ClampMagnitude = function(a, maxLength)
    if a:SqrMagnitude() > maxLength * maxLength then
        a:SetNormalize()
        a:Mul(maxLength)
    end
    return a
end

FixedVector3.SetNormalize = function(a)
    local num = a:Magnitude()
    if num == FixedNumber.ZERO then
        a:Copy(FixedVector3.ZERO)
    else
        a.x = a.x / num
        a.y = a.y / num
        a.z = a.z / num
    end
    return a
end

FixedVector3.SqrDistance = function(a, b)
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y) + (a.z - b.z) * (a.z - b.z)
end

FixedVector3.Distance = function(a, b)
    return FixedMath.Sqrt(FixedVector3.SqrDistance(a, b))
end

FixedVector3.Dot = function(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

FixedVector3.Lerp = function(a, b, t)
    if t <= FixedNumber.ZERO then
        return a:Clone()
    elseif t >= FixedNumber.ONE then
        return b:Clone()
    end
    return FixedVector3.New(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t)
end

FixedVector3.Max = function(a, b)
    return FixedVector3.New(FixedMath.Max(a.x, b.x), FixedMath.Max(a.y, b.y), FixedMath.Max(a.z, b.z))
end

FixedVector3.Min = function(a, b)
    return FixedVector3.New(FixedMath.Min(a.x, b.x), FixedMath.Min(a.y, b.y), FixedMath.Min(a.z, b.z))
end

FixedVector3.Angle = function(a, b)
    local t = FixedVector3.Dot(a:Normalize(), b:Normalize())
    return FixedMath.Rad2Deg(FixedMath.Acos(FixedMath.Clamp(t, FixedNumber.NEG_ONE, FixedNumber.ONE)))
end

FixedVector3.OrthoNormalize = function(a, b, c)
    a:SetNormalize()
    b:Sub(b:Project(a))
    b:SetNormalize()
    if c == nil then
        return a, b
    end
    c:Sub(c:Project(a))
    c:Sub(c:Project(b))
    c:SetNormalize()
    return a, b, c
end

FixedVector3.MoveTowards = function(current, target, maxDistanceDelta)
    local delta = target - current
    local sqrDelta = delta:SqrMagnitude()
    local sqrDistance = maxDistanceDelta * maxDistanceDelta
    if sqrDelta > sqrDistance then
        local magnitude = FixedMath.Sqrt(sqrDelta)
        if magnitude > FixedNumber.ZERO then
            delta:Mul(maxDistanceDelta / magnitude)
            delta:Add(current)
            return delta
        else
            return current:Clone()
        end
    end
    return target:Clone()
end

local function ClampedMove(a, b, clampedDelta)
    local delta = b - a
    if delta > FixedNumber.ZERO then
        return a + FixedMath.Min(delta, clampedDelta)
    else
        return a - FixedMath.Min(-delta, clampedDelta)
    end
end

local function OrthoNormalVector(vec)
    if FixedMath.Abs(vec.z) > FixedMath.HALF_SQRT2 then
        local a = vec.y * vec.y + vec.z * vec.z
        local k = FixedNumber.ONE / FixedMath.Sqrt(a)
        return FixedVector3.New(FixedNumber.ZERO, -vec.z * k, vec.y * k)
    else
        local a = vec.x * vec.x + vec.y * vec.y
        local k = FixedNumber.ONE / FixedMath.Sqrt(a)
        return FixedVector3.New(-vec.y * k, vec.x * k, FixedNumber.ZERO);
    end
end

FixedVector3.RotateTowards = function(current, target, maxRadiansDelta, maxMagnitudeDelta)
    local len1 = current:Magnitude()
    local len2 = target:Magnitude()
    if len1 > FixedNumber.ZERO and len2 > FixedNumber.ZERO then
        local from = current / len1
        local to = target / len2
        local cosom = FixedVector3.Dot(from, to)
        if cosom >= FixedNumber.ONE then
            return FixedVector3.MoveTowards(current, target, maxMagnitudeDelta)
        elseif cosom <= FixedNumber.NEG_ONE then
            local axis = OrthoNormalVector(from)
            local q = FixedQuaternion.AngleAxis(FixedMath.Rad2Deg(maxRadiansDelta), axis)
            local rotated = q:MulVec3(from)
            local delta = ClampedMove(len1, len2, maxMagnitudeDelta)
            rotated:Mul(delta)
            return rotated
        else
            local angle = FixedMath.Acos(cosom)
            local axis = FixedVector3.Cross(from, to)
            axis:SetNormalize()
            local q = FixedQuaternion.AngleAxis(FixedMath.Rad2Deg(FixedMath.Min(maxRadiansDelta, angle)), axis)
            local rotated = q:MulVec3(from)
            local delta = ClampedMove(len1, len2, maxMagnitudeDelta)
            rotated:Mul(delta)
            return rotated
        end
    end
    return FixedVector3.MoveTowards(current, target, maxMagnitudeDelta)
end

local DOT48 = FixedNumber.FromRaw(FixedConsts.DOT48)
local DOT235 = FixedNumber.FromRaw(FixedConsts.DOT235)

FixedVector3.SmoothDamp = function(current, target, smoothTime, maxSpeed, deltaTime, currentVelocity)
    smoothTime = FixedMath.Max(FixedNumber.DOT0001, smoothTime)
    local num = FixedNumber.TWO / smoothTime
    local num2 = num * deltaTime
    local num3 = FixedNumber.ONE / (FixedNumber.ONE + num2 + DOT48 * num2 * num2 + DOT235 * num2 * num2 * num2)
    local vec2 = target:Clone()
    local maxLength = maxSpeed * smoothTime
    local vec = current - target
    vec:ClampMagnitude(maxLength)
    target = current - vec
    local vec3 = (currentVelocity + (vec * num)) * deltaTime
    currentVelocity = (currentVelocity - (vec3 * num)) * num3
    local vec4 = target + (vec + vec3) * num3
    if FixedVector3.Dot(vec2 - current, vec4 - vec2) > FixedNumber.ZERO then
        vec4 = vec2
        currentVelocity:Set(FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO)
    end
    return vec4, currentVelocity
end

FixedVector3.Scale = function(a, b)
    return FixedVector3.New(a.x * b.x, a.y * b.y, a.z * b.z)
end

FixedVector3.Cross = function(a, b)
    return FixedVector3.New(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
end

FixedVector3.Reflect = function(a, b)
    local num = FixedNumber.NEG_TWO * FixedVector3.Dot(b, a)
    return b * num + a
end

FixedVector3.Project = function(a, b)
    local num = b:SqrMagnitude()
    if num <= FixedNumber.ZERO then
        return FixedVector3.ZERO:Clone()
    end
    local num2 = FixedVector3.Dot(a, b)
    return b * (num2 / num)
end

FixedVector3.ProjectOnPlane = function(v, p)
    return v - FixedVector3.Project(v, p)
end

FixedVector3.Slerp = function(from, to, t)
    if t <= FixedNumber.ZERO then
        return from:Clone()
    elseif t >= FixedNumber.ONE then
        return to:Clone()
    end
    local scale0
    local scale1
    local v2      = to:Clone()
    local v1      = from:Clone()
    local len2    = to:Magnitude()
    local len1    = from:Magnitude()
    v2:Div(len2)
    v1:Div(len1)
    local len     = (len2 - len1) * t + len1
    local cosom   = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
    if cosom >= FixedNumber.ONE then
        scale0 = FixedNumber.ONE - t
        scale1 = t
    elseif cosom <= FixedNumber.NEG_ONE then
        local axis = OrthoNormalVector(from)
        local q = FixedQuaternion.AngleAxis(FixedNumber.NUM180 * t, axis)
        local v = q:MulVec3(from)
        v:Mul(len)
        return v
    else
        local omega  = FixedMath.Acos(cosom)
        local sinom  = FixedMath.Sin(omega)
        scale0 = FixedMath.Sin((FixedNumber.ONE - t) * omega) / sinom
        scale1 = FixedMath.Sin(t * omega) / sinom
    end
    v1:Mul(scale0)
    v2:Mul(scale1)
    v2:Add(v1)
    v2:Mul(len)
    return v2
end

FixedVector3.AngleAroundAxis = function(from, to, axis)
    from = from - FixedVector3.Project(from, axis)
    to = to - FixedVector3.Project(to, axis)
    local angle = FixedVector3.Angle(from, to)
    return FixedVector3.Dot(axis, FixedVector3.Cross(from, to)) < FixedNumber.ZERO and -angle or angle
end

function FixedVector3:Add(vb)
    self.x = self.x + vb.x
    self.y = self.y + vb.y
    self.z = self.z + vb.z
    return self
end

function FixedVector3:Sub(vb)
    self.x = self.x - vb.x
    self.y = self.y - vb.y
    self.z = self.z - vb.z
    return self
end

function FixedVector3:Mul(q)
    self.x = self.x * q
    self.y = self.y * q
    self.z = self.z * q
    return self
end

function FixedVector3:Div(d)
    self.x = self.x / d
    self.y = self.y / d
    self.z = self.z / d
    return self
end

FixedVector3.__index = FixedVector3

FixedVector3.__tostring = function(a)
    return "["..tostring(a.x)..","..tostring(a.y)..","..tostring(a.z).."]"
end

FixedVector3.__add = function(va, vb)
    return FixedVector3.New(va.x + vb.x, va.y + vb.y, va.z + vb.z)
end

FixedVector3.__sub = function(va, vb)
    return FixedVector3.New(va.x - vb.x, va.y - vb.y, va.z - vb.z)
end

FixedVector3.__mul = function(va, d)
    return FixedVector3.New(va.x * d, va.y * d, va.z * d)
end

FixedVector3.__div = function(va, d)
    return FixedVector3.New(va.x / d, va.y / d, va.z / d)
end

FixedVector3.__unm = function(va)
    return FixedVector3.New(-va.x, -va.y, -va.z)
end

FixedVector3.__eq = function(a, b)
    return a.x == b.x and a.y == b.y and a.z == b.z
end

FixedVector3.UP      = FixedVector3.New(FixedNumber.ZERO, FixedNumber.ONE, FixedNumber.ZERO)
FixedVector3.DOWN    = FixedVector3.New(FixedNumber.ZERO, FixedNumber.NEG_ONE, FixedNumber.ZERO)
FixedVector3.RIGHT   = FixedVector3.New(FixedNumber.ONE, FixedNumber.ZERO, FixedNumber.ZERO)
FixedVector3.LEFT    = FixedVector3.New(FixedNumber.NEG_ONE, FixedNumber.ZERO, FixedNumber.ZERO);
FixedVector3.FORWARD = FixedVector3.New(FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ONE);
FixedVector3.BACK    = FixedVector3.New(FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.NEG_ONE);
FixedVector3.ZERO    = FixedVector3.New(FixedNumber.ZERO, FixedNumber.ZERO, FixedNumber.ZERO);
FixedVector3.ONE     = FixedVector3.New(FixedNumber.ONE, FixedNumber.ONE, FixedNumber.ONE);

return FixedVector3