local FixedQuaternion = {}

local ZERO                     = FixedNumber.ZERO
local ONE                      = FixedNumber.ONE
local TWO                      = FixedNumber.TWO
local HALF                     = FixedNumber.HALF
local NEG_ONE                  = FixedNumber.NEG_ONE

local PI                       = FixedMath.PI
local RAD2DEG                  = FixedMath.RAD2DEG
local DEG2RAD                  = FixedMath.DEG2RAD
local Clamp                    = FixedMath.Clamp
local Min                      = FixedMath.Min
local Max                      = FixedMath.Max
local Sqrt                     = FixedMath.Sqrt
local Sin                      = FixedMath.Sin
local Cos                      = FixedMath.Cos
local Asin                     = FixedMath.Asin
local Acos                     = FixedMath.Acos
local Atan2                    = FixedMath.Atan2

local RIGHT                    = FixedVector3.RIGHT
local FORWARD                  = FixedVector3.FORWARD
local UP                       = FixedVector3.UP

local DOT95                    = FixedNumber.New(0.95)
local HALF_PI                  = PI / TWO
local TWO_PI                   = TWO * PI
local NEG_FLIP                 = FixedNumber.New(-0.0001)
local POS_FLIP                 = TWO_PI + NEG_FLIP

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

FixedQuaternion.Get = function(a)
    return a.x, a.y, a.z, a.w
end

FixedQuaternion.Set = function(a, x, y, z, w)
    a.x = x:Clone()
    a.y = y:Clone()
    a.z = z:Clone()
    a.w = w:Clone()
    return a
end

FixedQuaternion.SetEuler = function(a, x, y, z)
    x = x * DEG2RAD / TWO
    y = y * DEG2RAD / TWO
    z = z * DEG2RAD / TWO
    local sinX = Sin(x)
    local cosX = Cos(x)
    local sinY = Sin(y)
    local cosY = Cos(y)
    local sinZ = Sin(z)
    local cosZ = Cos(z)
    a.w = cosY * cosX * cosZ + sinY * sinX * sinZ
    a.x = cosY * sinX * cosZ + sinY * cosX * sinZ
    a.y = sinY * cosX * cosZ - cosY * sinX * sinZ
    a.z = cosY * cosX * sinZ - sinY * sinX * cosZ
    return a
end

FixedQuaternion.Normalize = function(a)
    return a:Clone():SetNormalize()
end

FixedQuaternion.SetNormalize = function(a)
    local n = Sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)
    if n > ZERO then
        a.x = a.x / n
        a.y = a.y / n
        a.z = a.z / n
        a.w = a.w / n
    end
    return a
end

FixedQuaternion.SetFromToRotation1 = function(a, from, to)
    local v0 = from:Normalize()
    local v1 = to:Normalize()
    local d = FixedVector3.Dot(v0, v1)
    if d > NEG_ONE then
        local s = Sqrt((ONE + d) * TWO)
        local invs = ONE / s
        local c = FixedVector3.Cross(v0, v1) * invs
        a:Set(c.x, c.y, c.z, s / TWO)
    elseif d >= ONE then
        a:Set(ZERO, ZERO, ZERO, ONE)
    else
        local axis = FixedVector3.Cross(RIGHT, v0)
        if axis:SqrMagnitude() <= ZERO then
            axis = FixedVector3.Cross(FORWARD, v0)
        end
        a:Set(axis.x, axis.y, axis.z, ZERO)
    end
    return a
end

local function MatrixToQuaternion(rot, quat)
    local trace = rot[1][1] + rot[2][2] + rot[3][3]
    if trace > ZERO then
        local s = Sqrt(trace + ONE)
        quat.w = s / TWO
        s = ONE / (TWO * s)
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
        local NEXT = {2, 3, 1}
        local j = NEXT[i]
        local k = NEXT[j]
        local t = rot[i][i] - rot[j][j] - rot[k][k] + ONE
        local s = ONE / (TWO * Sqrt(t))
        q[i] = s * t
        local w = (rot[k][j] - rot[j][k]) * s
        q[j] = (rot[j][i] + rot[i][j]) * s
        q[k] = (rot[k][i] + rot[i][k]) * s
        quat:Set(q[1], q[2], q[3], w)
        quat:SetNormalize()
    end
end

FixedQuaternion.SetFromToRotation = function(a, from, to)
    from = from:Normalize()
    to = to:Normalize()
    local e = FixedVector3.Dot(from, to)
    if e >= ONE then
        a:Set(ZERO, ZERO, ZERO, ONE)
    elseif e <= NEG_ONE then
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

        local rot = {
            {fxx + uxx + lxx, fxy + uxy + lxy, fxz + uxz + lxz},
            {fxy + uxy + lxy, fyy + uyy + lyy, fyy + uyy + lyy},
            {fxz + uxz + lxz, fyz + uyz + lyz, fzz + uzz + lzz},
        }
        MatrixToQuaternion(rot, a)
    else
        local v = FixedVector3.Cross(from, to)
        local h = (ONE - e) / FixedVector3.Dot(v, v)
        local hx = h * v.x
        local hz = h * v.z
        local hxy = hx * v.y
        local hxz = hx * v.z
        local hyz = hz * v.y

        local rot = {
            {e + hx * v.x, hxy - v.z, hxz + v.y},
            {hxy + v.z, e + h * v.y * v.y, hyz - v.x},
            {hxz - v.y, hyz + v.x, e + hz * v.z},
        }
        MatrixToQuatenernion(rot, a)
    end
    return a
end

FixedQuaternion.Inverse = function(a)
    return FixedQuaternion.New(-a.x, -a.y, -a.z, a.w)
end

FixedQuaternion.SetIndentity = function(a)
    a.x = ZERO
    a.y = ZERO
    a.z = ZERO
    a.w = ONE
    return a
end

FixedQuaternion.ToAngleAxis = function(a)
    local angle = TWO * Acos(a.w)
    if angle == ZERO then
        return angle * RAD2DEG, FixedVector3.New(ONE, ZERO, ZERO)
    end
    local div = ONE / Sqrt(ONE - Sqrt(a.w))
    return angle * RAD2DEG, Vector3.New(a.x * div, a.y * div, a.z * div)
end

local function SanitizeEuler(euler)
    if euler.x < NEG_FLIP then
        euler.x = euler.x + TWO_PI
    elseif euler.x > POS_FLIP then
        euler.x = euler.x - TWO_PI
    end
    if euler.y < NEG_FLIP then
        euler.y = euler.y + TWO_PI
    elseif euler.y > POS_FLIP then
        euler.y = euler.y - TWO_PI
    end
    if euler.z < NEG_FLIP then
        euler.z = euler.z + TWO_PI
    elseif euler.z > POS_FLIP then
        euler.z = euler.z + TWO_PI
    end
end

FixedQuaternion.ToEulerAngles = function(a)
    local x = a.x
    local y = a.y
    local z = a.z
    local w = a.w
    local check = TWO * (y * z - w * x)
    if check < ONE + NEG_FLIP then
        if check > NEG_ONE - NEG_FLIP then
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
        local v = FixedVector3.New(-HALF_PI
            , Atan2(-TWO * (x * y - w * z), ONE - TWO * (y * y + z * z))
            , ZERO)
        SanitizeEuler(v)
        v:Mul(RAD2DEG)
        return v
    end
end

FixedQuaternion.Forward = function(a)
    return a:MulVec3(FORWARD)
end

FixedQuaternion.MulVec3 = function(a, point)
    local vec   = FixedVector3.New(ZERO, ZERO, ZERO)
    local num   = a.x * TWO
    local num2  = a.y * TWO
    local num3  = a.z * TWO
    local num4  = a.x * num
    local num5  = a.y * num2
    local num6  = a.z * num3
    local num7  = a.x * num2
    local num8  = a.x * num3
    local num9  = a.y * num3
    local num10 = a.w * num
    local num11 = a.w * num2
    local num12 = a.w * num3
    vec.x = (((ONE - (num5 + num6)) * point.x) + ((num7 - num12) * point.y))
        + ((num8 + num11) * point.z)
    vec.y = (((num7 + num12) * point.x) + ((ONE - (num4 + num6)) * point.y))
        + ((num9 - num10) * point.z)
    vec.z = (((num8 - num11) * point.x) + ((num9 + num10) * point.y))
        + ((ONE - (num4 + num5)) * point.z)
    return vec
end

FixedQuaternion.Dot = function(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

FixedQuaternion.Angle = function(a, b)
    local dot = FixedQuaternion.Dot(a, b)
    if dot < ZERO then
        dot = -dot
    end
    return Acos(Min(dot, ONE)) * TWO * RAD2DEG
end

FixedQuaternion.AngleAxis = function(angle, axis)
    local normAxis = axis:Normalize()
    angle = angle * DEG2RAD / TWO
    local s = Sin(angle)
    local w = Cos(angle)
    local x = normAxis.x * s
    local y = normAxis.y * s
    local z = normAxis.z * s
    return FixedQuaternion.New(x, y, z, w)
end

FixedQuaternion.Euler = function(x, y, z)
    local t = FixedQuaternion.New(ZERO, ZERO, ZERO, ONE)
    return t:SetEuler(x, y, z)
end

FixedQuaternion.FromToRotation = function(from, to)
    local t = FixedQuaternion.New(ZERO, ZERO, ZERO, ONE)
    return t:SetFromToRotation(from, to)
end

FixedQuaternion.Lerp = function(q1, q2, t)
    t = Clamp(t, ZERO, ONE)
    local q = FixedQuaternion.New(ZERO, ZERO, ZERO, ONE)
    if FixedQuaternion.Dot(q1, q2) < ZERO then
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

FixedQuaternion.LookRotation = function(forward, up)
    local mag = forward:Magnitude()
    if mag <= ZERO then
        error("error input forward "..tostring(forward))
        return nil
    end
    forward = forward / mag
    up = up or UP
    local right = FixedVector3.Cross(up, forward)
    right:SetNormalize()
    up = FixedVector3.Cross(forward, right)
    right = FixedVector3.Cross(up, forward)
    local quat = FixedQuaternion.New(ZERO, ZERO, ZERO, ONE)
    local rot = {
        {right.x, up.x, forward.x},
        {right.y, up.y, forward.y},
        {right.z, up.z, forward.z},
    };
    MatrixToQuaternion(rot, quat);
    return quat
end

local function UnclampedSlerp(q1, q2, t)
    local dot = FixedQuaternion.Dot(q1, q2)
    if dot < ZERO then
        dot = -dot
        q2 = -q2
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

FixedQuaternion.Slerp = function(from, to, t)
    return UnclampedSlerp(from, to, Clamp(t, ZERO, ONE))
end

FixedQuaternion.RotateTowards = function(from, to, maxDegreesDelta)
    local angle = FixedQuaternion.Angle(from, to)
    if angle == ZERO then
        return to
    end
    local t = Min(ONE, maxDegreesDelta / angle)
    return UnclampedSlerp(from, to, t)
end

FixedQuaternion.INDENTITY = FixedQuaternion.New(ZERO, ZERO, ZERO, ONE)

FixedQuaternion.__index = FixedQuaternion

FixedQuaternion.__tostring = function(self)
    return "["..self.x..","..self.y..","..self.z..","..self.w.."]"
end

FixedQuaternion.__mul = function(a, b)
    return Quaternion.New(
        (((a.w * b.x) + (a.x * b.w)) + (a.y * b.z)) - (a.z * b.y)
        , (((a.w * b.y) + (a.y * b.w)) + (a.z * b.x)) - (a.x * b.z)
        , (((a.w * b.z) + (a.z * b.w)) + (a.x * b.y)) - (a.y * b.x)
        , (((a.w * b.w) - (a.x * b.x)) - (a.y * b.y)) - (a.z * b.z))
end

FixedQuaternion.__unm = function(a)
    return FixedQuaternion.New(-a.x, -a.y, -a.z, -a.w)
end

FixedQuaternion.__eq = function(a, b)
    return FixedQuaternion.Dot(a, b) >= ONE
end

return FixedQuaternion
