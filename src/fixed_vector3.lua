local FixedVector3 = {}

local ZERO                 = FixedNumber.ZERO
local ONE                  = FixedNumber.ONE
local TWO                  = FixedNumber.TWO
local NEG_ONE              = FixedNumber.NEG_ONE

local PI                   = FixedMath.PI
local RAD2DEG              = FixedMath.RAD2DEG
local DEG2RAD              = FixedMath.DEG2RAD

local Clamp                = FixedMath.Clamp
local Min                  = FixedMath.Min
local Max                  = FixedMath.Max
local Abs                  = FixedMath.Abs
local Sqrt                 = FixedMath.Sqrt
local Sin                  = FixedMath.Sin
local Cos                  = FixedMath.Cos
local Acos                 = FixedMath.Acos

local OVER_SQRT2           = FixedNumber.New(0.7071067811)
local MIN_SMOOTH_TIME      = FixedNumber.New(0.0001)
local DOT48                = FixedNumber.New(0.48)
local DOT235               = FixedNumber.New(0.235)
local PI_ANGLE             = FixedNumber.New(180)

FixedVector3.New = function(x, y, z)
    local t = {
        x = FixedNumber.New(x),
        y = FixedNumber.New(y),
        z = FixedNumber.New(z),
    }
    setmetatable(t, FixedVector3)
    return t
end

FixedVector3.Clone = function(a)
    return FixedVector3.New(a.x, a.y, a.z)
end

FixedVector3.Get = function(a)
    return a.x, a.y, a.z
end

FixedVector3.Set = function(a, x, y, z)
    a.x = x:Clone()
    a.y = y:Clone()
    a.z = z:Clone()
    return a
end

FixedVector3.SqrMagnitude = function(a)
    return a.x * a.x + a.y * a.y + a.z * a.z
end

FixedVector3.Magnitude = function(a)
    return Sqrt(a:SqrMagnitude())
end

FixedVector3.Normalize = function(a)
    local num = a:Magnitude()
    if num == ZERO then
        return FixedVector3.New(ZERO, ZERO, ZERO)
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
    if num == ZERO then
        a:Set(ZERO, ZERO, ZERO)
    else
        a.x = a.x / num
        a.y = a.y / num
        a.z = a.z / num
    end
    return a
end

FixedVector3.SqrDistance = function(a, b)
    return (a.x - b.x) * (a.x - b.x)
        + (a.y - b.y) * (a.y - b.y)
        + (a.z - b.z) * (a.z - b.z)
end

FixedVector3.Distance = function(a, b)
    return Sqrt(FixedVector3.SqrDistance(a, b))
end

FixedVector3.Dot = function(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

FixedVector3.Lerp = function(a, b, t)
    if t <= ZERO then
        return a:Clone()
    elseif t >= ONE then
        return b:Clone()
    end
    return FixedVector3.New(
        a.x + (b.x - a.x) * t
        , a.y + (b.y - a.y) * t
        , a.z + (b.z - a.z) * t)
end

FixedVector3.Max = function(a, b)
    return FixedVector3.New(Max(a.x, b.x), Max(a.y, b.y), Max(a.z, b.z))
end

FixedVector3.Min = function(a, b)
    return FixedVector3.New(Min(a.x, b.x), Min(a.y, b.y), Min(a.z, b.z))
end

FixedVector3.Angle = function(a, b)
    local t = FixedVector3.Dot(a:Normalize(), b:Normalize())
    return Acos(Clamp(t, NEG_ONE, ONE)) * RAD2DEG
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
        local magnitude = Sqrt(sqrDelta)
        if magnitude > ZERO then
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
    if delta > ZERO then
        return a + Min(delta, clampedDelta)
    else
        return a - Min(-delta, clampedDelta)
    end
end

local function OrthoNormalVector(vec)
    if Abs(vec.z) > OVER_SQRT2 then
        local a = vec.y * vec.y + vec.z * vec.z
        local k = ONE / Sqrt(a)
        return FixedVector3.New(ZERO, -vec.z * k, vec.y * k)
    else
        local a = vec.x * vec.x + vec.y * vec.y
        local k = ONE / Sqrt(a)
        return FixedVector3.New(-vec.y * k, vec.x * k, ZERO);
    end
end

FixedVector3.RotateTowards = function(current, target, maxRadiansDelta, maxMagnitudeDelta)
    local len1 = current:Magnitude()
    local len2 = target:Magnitude()
    if len1 > ZERO and len2 > ZERO then
        local from = current / len1
        local to = target / len2
        local cosom = FixedVector3.Dot(from, to)
        if cosom >= ONE then
            return FixedVector3.MoveTowards(current, target, maxMagnitudeDelta)
        elseif cosom <= NEG_ONE then
            local axis = OrthoNormalVector(from)
            local q = FixedQuaternion.AngleAxis(maxRadiansDelta * RAD2DEG, axis)
            local rotated = q:MulVec3(from)
            local delta = ClampedMove(len1, len2, maxMagnitudeDelta)
            rotated:Mul(delta)
            return rotated
        else
            local angle = Acos(cosom)
            local axis = FixedVector3.Cross(from, to)
            axis:SetNormalize()
            local q = FixedQuaternion.AngleAxis(Min(maxRadiansDelta, angle) * RAD2DEG, axis)
            local rotated = q:MulVec3(from)
            local delta = ClampedMove(len1, len2, maxMagnitudeDelta)
            rotated:Mul(delta)
            return rotated
        end
    end
    return FixedVector3.MoveTowards(current, target, maxMagnitudeDelta)
end

FixedVector3.SmoothDamp = function(current, target, smoothTime, maxSpeed, deltaTime, currentVelocity)
    smoothTime = Max(MIN_SMOOTH_TIME, smoothTime)
    local num = TWO / smoothTime
    local num2 = num * deltaTime
    local num3 = ONE / (ONE + num2 + DOT48 * num2 * num2 + DOT235 * num2 * num2 * num2)
    local vec2 = target:Clone()
    local maxLength = maxSpeed * smoothTime
    local vec = current - target
    vec:ClampMagnitude(maxLength)
    target = current - vec
    local vec3 = (currentVelocity + (vec * num)) * deltaTime
    currentVelocity = (currentVelocity - (vec3 * num)) * num3
    local vec4 = target + (vec + vec3) * num3
    if FixedVector3.Dot(vec2 - current, vec4 - vec2) > ZERO then
        vec4 = vec2
        currentVelocity:Set(ZERO, ZERO, ZERO)
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
    local num = -TWO * FixedVector3.Dot(b, a)
    return b * num + a
end

FixedVector3.Project = function(a, b)
    local num = b:SqrMagnitude()
    if num <= ZERO then
        return FixedVector3.New(ZERO, ZERO, ZERO)
    end
    local num2 = FixedVector3.Dot(a, b)
    return b * (num2 / num)
end

FixedVector3.ProjectOnPlane = function(v, p)
    return v - FixedVector3.Project(v, p)
end

FixedVector3.Slerp = function(from, to, t)
    if t <= ZERO then
        return from:Clone()
    elseif t >= ONE then
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
    if cosom >= ONE then
        scale0 = ONE - t
        scale1 = t
    elseif cosom <= NEG_ONE then
        local axis = OrthoNormalVector(from)
        local q = FixedQuaternion.AngleAxis(PI_ANGLE * t, axis)
        local v = q:MulVec3(from)
        v:Mul(len)
        return v
    else
        local omega  = Acos(cosom)
        local sinom  = Sin(omega)
        scale0 = Sin((ONE - t) * omega) / sinom
        scale1 = Sin(t * omega) / sinom
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
    return angle * (FixedVector3.Dot(axis, FixedVector3.Cross(from, to)) < ZERO
            and NEG_ONE or ONE)
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

FixedVector3.__tostring = function(self)
    return "["..self.x..","..self.y..","..self.z.."]"
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
    return (a - b):SqrMagnitude() == ZERO
end

FixedVector3.UP      = FixedVector3.New(ZERO, ONE, ZERO)
FixedVector3.DOWN    = FixedVector3.New(ZERO, NEG_ONE, ZERO)
FixedVector3.RIGHT   = FixedVector3.New(ONE, ZERO, ZERO)
FixedVector3.LEFT    = FixedVector3.New(NEG_ONE, ZERO, ZERO);
FixedVector3.FORWARD = FixedVector3.New(ZERO, ZERO, ONE);
FixedVector3.BACK    = FixedVector3.New(ZERO, ZERO, NEG_ONE);
FixedVector3.ZERO    = FixedVector3.New(ZERO, ZERO, ZERO);
FixedVector3.ONE     = FixedVector3.New(ONE, ONE, ONE);

return FixedVector3
