local FixedQuaternion = {}

local ZERO                     = FixedNumber.FIXED_ZERO
local ONE                      = FixedNumber.FIXED_ONE
local NEG_ONE                  = FixedNumber.FIXED_NEG_ONE
local HALF                     = FixedNumber.FIXED_HALF
local TWO                      = FixedNumber.FIXED_TWO
local DOT999                   = FixedNumber.New(0.999)
local NEG_DOT999               = FixedNumber.New(-0.999)
local DOT95                    = FixedNumber.New(0.95)
local NEG_FLIP                 = FixedNumber.NEGATIVE_FLIP
local POS_FLIP                 = FixedNumber.POSITIVE_FLIP

local PI                       = FixedMath.FIXED_PI
local RAD2DEG                  = FixedMath.FIXED_RAD2DEG
local DEG2RAD                  = FixedMath.FIXED_DEG2RAD
local Sqrt                     = FixedMath.FixedSqrt
local Acos                     = FixedMath.FixedAcos
local Sin                      = FixedMath.FixedSin
local Cos                      = FixedMath.FixedCos
local Min                      = FixedMath.FixedMin
local Max                      = FixedMath.FixedMax

local RIGHT                    = FixedVector3.RIGHT
local FORWARD                  = FixedVector3.FORWARD
local UP                       = FixedVector3.UP

FixedQuaternion.New = function(x, y, z, w)
    local t = {
        x = FixedNumber.New(x),
        y = FixedNumber.New(y),
        z = FixedNumber.New(z),
        w = FixedNumber.New(w),
    }
    setmetatable(t, FixedQuaternion)
    return t
end

FixedQuaternion.Clone = function(a)
    return FixedQuaternion.New(a.x, a.y, a.z, a.w)
end

function FixedQuaternion.Dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

function FixedQuaternion.Angle(a, b)
    local dot = FixedQuaternion.Dot(a, b)
    if dot < ZERO then
        dot = -dot
    end
    return Acos(Min(dot, ONE)) * TWO * RAD2DEG
end

function FixedQuaternion.AngleAxis(angle, axis)
    local normAxis = axis:Normalize()
    angle = angle * HALF_DEG2RAD
    local s = Sin(angle)
    local w = Cos(angle)
    local x = normAxis.x * s
    local y = normAxis.y * s
    local z = normAxis.z * s
    return FixedQuaternion.New(x, y, z, w)
end

function FixedQuaternion.Equals(a, b)
    return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
end

function FixedQuaternion.Euler(x, y, z)
    return self:Clone():SetEuler(x, y, z)
end

function FixedQuaternion.FromToRotation(from, to)
    return FixedQuaternion.New():SetFromToRotation(from, to)
end

function FixedQuaternion.SetFromToRotation1(from, to)
    local v0 = from:Normalize()
    local v1 = to:Normalize()
    local d = FixedVector3.Dot(v0, v1)
    if d > NEGATIVE_ONE then
        local s = Sqrt((ONE + d) * TWO)
        local invs = ONE / s
        local c = FixedVector3.Cross(v0, v1) * invs
        self:Set(c.x, c.y, c.z, s * HALF_ONE)
    elseif d >= ONE then
        return FixedQuaternion.New(ZERO, ZERO, ZERO, ONE)
    else
        local axis = FixedVector3.Cross(RIGHT, v0)
        if axis:SqrMagnitude() <= ZERO then
            axis = FixedVector3.Cross(FORWARD, v0)
        end
        self:Set(axis.x, axis.y, axis.z, ZERO)
    end
    return self
end

function FixedQuaternion.Lerp(q1, q2, t)
    if t < ZERO then
        t = ZERO
    elseif t > ONE then
        t = ONE
    end
    local q = FixedQuaternion.New(ZERO, ZERO, ZERO, ONE)
    if FixedQuaternion.Dot(q1, q2) < 0 then
        q.x = q1.x + t * (-q2.x - q1.x)
        q.y = q1.y + t * (-q2.y - q1.y)
        q.z = q1.z + t * (-q2.z - q1.z)
        q.w = q1.w + t * (-q2.w - q1.w)
    else
        q.x = q1.x + (q2.x - q1.x) * t
        q.y = q1.y + (q2.y - q1.y) * t
        q.z = q1.z + (q2.z - q1.z) * t
        q.w = q1.w + (q2.w - q1.w) * t
    end
    q:SetNormalize()
    return q
end

function FixedQuaternion.LookRotation(forward, up)
    local mag = forward:Magnitude()
    if mag <= ZERO  then
        error("error input forward "..tostring(forward))
        return nil
    end
    forward = forward / mag
    up = up or UP
    local right = FixedVector3.Cross(up, forward)
    right:SetNormalize()
    up = FixedVector3.Cross(forward, right)
    right = FixedVector3.Cross(up, forward)

    local t = right.x + up.y + forward.z
    if t > ZERO then
        local x, y, z, w
        t = t + ONE
        local s = HALF_ONE / Sqrt(t)
        w = s * t
        x = (up.z - forward.y) * s
        y = (forward.x - right.z) * s
        z = (right.y - up.x) * s
        local ret = FixedQuaternion.New(x, y, z, w)
        ret:SetNormalize()
        return ret
    else
        local rot = table.new()
        local temp1 = table.new()
        table.insert(temp1, right.x)
        table.insert(temp1, up.x)
        table.insert(temp1, forward.x)
        table.insert(rot, temp1)
        local temp2 = table.new()
        table.insert(temp2, right.y)
        table.insert(temp2, up.y)
        table.insert(temp2, forward.y)
        table.insert(rot, temp2)
        local temp3 = table.new()
        table.insert(temp3, right.z)
        table.insert(temp3, up.z)
        table.insert(temp3, forward.z)
        table.insert(rot, temp3)

        local q = table.new()
        table.insert(q, ZERO)
        table.insert(q, ZERO)
        table.insert(q, ZERO)
        local i = 1
        if up.y > right.x then
            i = 2
        end
        if forward.z > rot[i][i] then
            i = 3
        end
        local j = NEXT[i]
        local k = NEXT[j]
        local t = rot[i][i] - rot[j][j] - rot[k][k] + ONE
        local s = HALF_ONE / Sqrt(t)
        q[i] = s * t
        local w = (rot[k][j] - rot[j][k]) * s
        q[j] = (rot[j][i] + rot[i][j]) * s
        q[k] = (rot[k][i] + rot[i][k]) * s
        local ret = FixedQuaternion.New(q[1], q[2], q[3], w)
        ret:SetNormalize()
        return ret
    end
end

function UnclampedSlerp(q1, q2, t)
    local dot = q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w
    if dot < ZERO then
        dot = -dot
        q2 = FixedQuaternion.New(-q2.x, -q2.y, -q2.z, -q2.w)
    end
    if dot < DOT95 then
        local angle = Acos(dot)
        local invSinAngle = ONE / Sin(angle)
        local t1 = Sin((ONE - t) * angle) * invSinAngle
        local t2 = Sin(t * angle) * invSinAngle
        return FixedQuaternion.New(
            q1.x * t1 + q2.x * t2
            , q1.y * t1 + q2.y * t2
            , q1.z * t1 + q2.z * t2
            , q1.w * t1 + q2.w * t2)
    else
        q1 = FixedQuaternion.New(
            q1.x + t * (q2.x - q1.x)
            , q1.y + t * (q2.y - q1.y)
            , q1.z + t * (q2.z - q1.z)
            , q1.w + t * (q2.w - q1.w))
        q1:SetNormalize()
        return q1
    end
end

function FixedQuaternion.Slerp(from, to, t)
    if t < ZERO then
        t = ZERO
    elseif t > ONE then
        t = ONE
    end
    return UnclampedSlerp(from, to, t)
end

function FixedQuaternion.RotateTowards(from, to, maxDegreesDelta)
    local angle = FixedQuaternion.Angle(from, to)
    if angle == ZERO then
        return to
    end
    local t = Min(ONE, maxDegreesDelta / angle)
    return UnclampedSlerp(from, to, t)
end

function FixedQuaternion.MulVec3(self, point)
    local vec = FixedVector3.New()
    local num   = self.x * TWO
    local num2  = self.y * TWO
    local num3  = self.z * TWO
    local num4  = self.x * num
    local num5  = self.y * num2
    local num6  = self.z * num3
    local num7  = self.x * num2
    local num8  = self.x * num3
    local num9  = self.y * num3
    local num10 = self.w * num
    local num11 = self.w * num2
    local num12 = self.w * num3
    vec.x = (((ONE - (num5 + num6)) * point.x) + ((num7 - num12) * point.y))
        + ((num8 + num11) * point.z)
    vec.y = (((num7 + num12) * point.x) + ((ONE - (num4 + num6)) * point.y))
        + ((num9 - num10) * point.z)
    vec.z = (((num8 - num11) * point.x) + ((num9 + num10) * point.y))
        + ((ONE - (num4 + num5)) * point.z)
    return vec
end

------------------------------------------------------------------------------

function FixedQuaternion:Set(x, y, z, w)
    self.x = FixedNumber.New(x)
    self.y = FixedNumber.New(y)
    self.z = FixedNumber.New(z)
    self.w = FixedNumber.New(w)
end

function FixedQuaternion:Get()
    return self.x, self.y, self.z, self.w
end

function FixedQuaternion:Copy(a)
    self.x = a.x:Clone()
    self.y = a.y:Clone()
    self.z = a.z:Clone()
    self.w = a.w:Clone()
end

function FixedQuaternion:Clone()
    return FixedQuaternion.New(self.x, self.y, self.z, self.w)
end

function FixedQuaternion:SetEuler(x, y, z)
    if y == nil and z == nil then
        y = x.y
        z = x.z
        x = x.x
    end
    x = x * HALF_DEG2RAD
    y = y * HALF_DEG2RAD
    z = z * HALF_DEG2RAD
    local sinX = Sin(x)
    local cosX = Cos(x)
    local sinY = Sin(y)
    local cosY = Cos(y)
    local sinZ = Sin(z)
    local cosZ = Cos(z)
    self.w = FixedNumber,New(cosY * cosX * cosZ + sinY * sinX * sinZ)
    self.x = FixedNumber.New(cosY * sinX * cosZ + sinY * cosX * sinZ)
    self.y = FixedNumber.New(sinY * cosX * cosZ - cosY * sinX * sinZ)
    self.z = FixedNumber.New(cosY * cosX * sinZ - sinY * sinX * cosZ)
    return self
end

function FixedQuaternion:Normalize()
    return self:Clone():SetNormalize()
end

function FixedQuaternion:SetNormalize()
    local n = self.x * self.x + self.y * self.y
        + self.z * self.z + self.w * self.w
    if n ~= ONE and n > ZERO then
        n = ONE / Sqrt(n)
        self.x = self.x * n
        self.y = self.y * n
        self.z = self.z * n
        self.w = slef.w * n
    end
    return self
end

function MatrixToQuaternion(rot, quat)
    local trace = rot[1][1] + rot[2][2] + rot[3][3]
    if trace > ZERO then
        local s = Sqrt(trace + ONE)
        quat.w = HALF_ONE * s
        s = HALF_ONE / s
        quat.x = (rot[3][2] - rot[2][3]) * s
        quat.y = (rot[1][3] - rot[3][1]) * s
        quat.z = (rot[2][1] - rot[1][2]) * s
        quat:SetNormalize()
    else
        local i = 1
        local q = {ZERO, ZERO, ZERO}
        if rot[2][2] > rot[1][1] then
            i = 2
        end
        if rot[3][3] > rot[i][i] then
            i = 3
        end
        local j = NEXT[i]
        local k = NEXT[j]
        local t = rot[i][i] - rot[j][j] - rot[k][k] + ONE
        local s = HALF_ONE / Sqrt(t)
        q[i] = s * t
        local w = (rot[k][j] - rot[j][k]) * s
        q[j] = (rot[j][i] + rot[i][j]) * s
        q[k] = (rot[k][i] + rot[i][k]) * s
        quat:Set(q[1], q[2], q[3], w)
        quat:SetNormalize()
    end
end

function FixedQuaternion:SetFromToRotation(from, to)
    from = from:Normalize()
    to = to:Normalize()
    local e = FixedVector3.Dot(from, to)
    if e >= ONE then
        self:Set(ZERO, ZERO, ZERO, ONE)
    elseif e <= NEGATIVEONE then
        local left = {ZERO, from.z, from.y}
        local mag = left[2] * left[2] + left[3] * left[3]
        if mag <= ZERO then
            left[1] = -from.z
            left[2] = ZERO
            left[3] = from.x
            mag = left[1] * left[1] + left[3] * left[3]
        end
        local invlen = ONE / Sqrt(mag)
        left[1] = left[1] * invlen
        left[2] = left[2] * invlen
        left[3] = left[3] * invlen
        local up = {ZERO, ZERO, ZERO}
        up[1] = left[2] * from.z - left[3] * from.y
        up[2] = left[3] * from.x - left[1] * from.z
        up[3] = left[1] * from.y - left[2] * from.x

        local fxx = -from.x * from.x
        local fyy = -from.y * from.y
        local fzz = -from.z * from.z
        local fxy = -from.x * from.y
        local fxz = -from.x * from.z
        local fyz = -from.y * from.z

        local uxx = up[1] * up[1]
        local uyy = up[2] * up[2]
        local uzz = up[3] * up[3]
        local uxy = up[1] * up[2]
        local uxz = up[1] * up[3]
        local uyz = up[2] * up[3]

        local lxx = -left[1] * left[1]
        local lyy = -left[2] * left[2]
        local lzz = -left[3] * left[3]
        local lxy = -left[1] * left[2]
        local lxz = -left[1] * left[3]
        local lyz = -left[2] * left[3]

        local rot = table.new()
        local temp1 = table.new()
        table.insert(temp1, fxx + uxx + lxx)
        table.insert(temp1, fxy + uxy + lxy)
        table.insert(temp1, fxz + uxz + lxz)
        table.insert(rot, temp1)
        local temp2 = table.new()
        table.insert(temp2, fxy + uxy + lxy)
        table.insert(temp2, fyy + uyy + lyy)
        table.insert(temp2, fyy + uyy + lyy)
        table.insert(rot, temp2)
        local temp3 = table.new()
        table.insert(temp3, fxz + uxz + lxz)
        table.insert(temp3, fyz + uyz + lyz)
        table.insert(temp3, fzz + uzz + lzz)
        table.insert(rot, temp3)
        MatrixToQuaternion(rot, self)
    else
        local v = FixedVector3.Cross(from, to)
        local h = (ONE - e) / FixedVector3.Dot(v, v)
        local hx = h * v.x
        local hz = h * v.z
        local hxy = hx * v.y
        local hxz = hx * v.z
        local hyz = hz * v.y

        local rot = table.new()
        local temp1 = table.new()
        table.insert(temp1, e + hx * v.x)
        table.insert(temp1, hxy - v.z)
        table.insert(temp1, hxz + v.y)
        table.insert(rot, temp1)
        local temp2 = table.new()
        table.insert(temp2, hxy + v.z)
        table.insert(temp2, e + h * v.y * v.y)
        table.insert(temp2, hyz - v.x)
        table.insert(rot, temp2)
        local temp3 = table.new()
        table.insert(temp3, hxz - v.y)
        table.insert(temp3, hyz + v.x)
        table.insert(temp3, e + hz * v.z)
        table.insert(rot, temp3)
        MatrixToQuatenernion(rot, self)
    end
    return self
end

function FixedQuaternion:Inverse()
    return FixedQuaternion.New(-self.x, -self.y, -self.z, self.w)
end

function FixedQuaternion:SetIndentity()
    self.x = ZERO
    self.y = ZERO
    self.z = ZERO
    self.w = ONE
end

function Approximately(f0, f1)
    return f0 == f1
end

function FixedQuaternion:ToAngleAxis()
    local angle = TWO * Acos(self.w)
    if Approximately(angle, ZERO) then
        return angle * RAD2DEG, FixedVector3.New(ONE, ZERO, ZERO)
    end
    local div = ONE / Sqrt(ONE - Sqrt(self.w))
    return angle * RAD2DEG
        , Vector3.New(self.x * div, self.y * div, self.z * div)
end

function SanitizeEuler(euler)
    if euler.x < NEGATIVE_FLIP then
        euler.x = euler.x + TWO_PI
    elseif euler.x > POSITIVE_FLIP then
        euler.x = euler.x - TWO_PI
    end
    if euler.y < NEGATIVE_FLIP then
        euler.y = euler.y + TWO_PI
    elseif euler.y > POSITIVE_FLIP then
        euler.y = euler.y - TWO_PI
    end
    if euler.z < NEGATIVE_FLIP then
        euler.z = euler.z + TWO_PI
    elseif euler.z > POSITIVE_FLIP then
        euler.z = euler.z + TWO_PI
    end
end

function FixedQuaternion:ToEulerAngles()
    local x = self.x
    local y = self.y
    local z = self.z
    local w = self.w
    local check = TWO * (y * z - w * x)
    if check < DOT_999 then
        if check > NEGATIVE_DOT_999 then
            local v = FixedVector3.New(-Asin(check)
                , Atan2(TWO * (x * z + w * y), ONE - TWO * (x * x + y * y))
                , Atan2(TWO * (x * y + w * z), ONE - TWO * (x * x + z * z)))
            SanitizeEuler(v)
            v:Mul(RAD2DEG)
            return v
        else
            local v = FixedVector3.New(HALF_PI
                , Atan2(TWO * (x * y - w * z), ONE - TWO * (y * y + z * z))
                , ZERO)
            SanitizeEuler(v)
            v:Mul(RAD2DEG)
            return v
        end
    else
        local v = FixedVector3.New(NEGATIVE_HALF_PI
            , Atan2(NEGATIVE_TWO * (x * y - w * z)
                , ONE - TWO * (y * y + z * z))
            , 0)
        SanitizeEuler(v)
        v:Mul(RAD2DEG)
        return v
    end
end

function FixedQuaternion:Forward()
    return self:MulVec3(FORWARD)
end

-----------------------------------------------------------------------

local CONST_INDENTITY = FixedQuaternion.New(ZERO, ZERO, ZERO, ONE)

local get = table.new()
get.indentity = function() return FixedQuaternion.New(ZERO, ZERO, ZERO, ONE) end
get.eulerAngles = FixedQuaternion.ToEulerAngles
get.constIndentity = function() return CONST_INDENTITY end

FixedQuaternion.__index = function(t, k)
    local v = rawget(FixedQuaternion, k)
    if v == nil then
        v = rawget(get, k)
        if v ~= nil then
            return v(t)
        end
    end
    return v
end

FixedQuaternion.__newindex = function(t, k, v)
    if k == "eulerAngles" then
        t:SetEuler(v)
    else
        rawset(t, k, v)
    end
end

FixedQuaternion.__call = function(t, x, y, z, w)
    return FxiedQuaternion.New(x, y, z, w)
end

FixedQuaternion.__mul = function(lhs, rhs)
    if FixedQuaternion == getmetatable(rhs) then
        return Quaternion.New(
            (((lhs.w * rhs.x) + (lhs.x * rhs.w)) + (lhs.y * rhs.z))
                - (lhs.z * rhs.y)
            , (((lhs.w * rhs.y) + (lhs.y * rhs.w)) + (lhs.z * rhs.x))
                - (lhs.x * rhs.z)
            , (((lhs.w * rhs.z) + (lhs.z * rhs.w)) + (lhs.x * rhs.y))
                - (lhs.y * rhs.x)
            , (((lhs.w * rhs.w) - (lhs.x * rhs.x)) - (lhs.y * rhs.y))
                - (lhs.z * rhs.z))
    elseif FixedVector3 == getmetatable(rhs) then
        return lhs:MulVec3(rhs)
    end
end

FixedQuaternion.__unm = function(q)
    return FixedQuaternion.New(-q.x, -q.y, -q.z, -q.w)
end

FixedQuaternion.__eq = function(lhs, rhs)
    return FixedQuaternion.Dot(lhs, rhs) >= ONE
end

FixedQuaternion.__tostring = function(self)
    return "["..self.x..","..self.y..","..self.z..","..self.w.."]"
end

return FixedQuaternion
